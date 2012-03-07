//
//  TBSFTPPublisher.m
//  Tribo
//
//  Created by Carter Allen on 3/5/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSFTPPublisher.h"
#import "TBSite.h"

@interface TBSFTPPublisher ()
- (NSURL *)userSelectedIdentityURL;
- (NSString *)passwordFromKeychain;
@end

@implementation TBSFTPPublisher

- (NSURL *)userSelectedIdentityURL {
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.message = @"Please select the SSH identity file (usually called id_rsa or ida_dsa) that should be used to authenticate with the server. Identity files are typically found in the .ssh folder in your home directory.";
	panel.directoryURL = [[NSURL fileURLWithPath:NSHomeDirectory()] URLByAppendingPathComponent:@".ssh" isDirectory:YES];
	panel.showsHiddenFiles = YES;
	panel.allowsMultipleSelection = YES;
	NSInteger button = [panel runModal];
	
	if (button == NSFileHandlingPanelCancelButton) return nil;
	
	return [[panel URLs] objectAtIndex:0];
	
}

- (NSString *)passwordFromKeychain {
	
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = [self.site.metadata objectForKey:TBSiteServerKey];
	NSString *accountName = [self.site.metadata objectForKey:TBSiteUserNameKey];
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[[self.site.metadata objectForKey:TBSitePortKey] integerValue];
	SecProtocolType protocol = kSecProtocolTypeSSH;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, "", port, protocol, kSecAuthenticationTypeDefault, &passwordLength, (void **)&passwordBuffer, NULL);
	if (returnStatus != noErr)
		return nil;
	NSString *password = [[NSString alloc] initWithBytes:passwordBuffer length:passwordLength encoding: NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordBuffer);
	if ([password length] == 0) password = nil;
	return password;
	
}

- (void)publish {
	
	[self.site process:nil];
	
	NSTask *rsync = [[NSTask alloc] init];
	NSURL *bundledRsyncURL = [[NSBundle mainBundle] URLForResource:@"rsync" withExtension:@""];
	rsync.launchPath = bundledRsyncURL.path;
	
	NSPipe *outputPipe = [NSPipe pipe];
	rsync.standardOutput = outputPipe;
	NSPipe *errorPipe = [NSPipe pipe];
	rsync.standardError = errorPipe;
	NSPipe *nullFileHandle = [NSFileHandle fileHandleWithNullDevice];
	rsync.standardInput = nullFileHandle;
	
	NSMutableArray *arguments = [NSMutableArray array];
	
	[arguments addObject:@"--recursive"];
	[arguments addObject:@"--times"];
	[arguments addObject:@"--compress"];
	[arguments addObject:@"--info=progress2"];
	[arguments addObject:[self.site.destination.path stringByAppendingString:@"/"]];
	
	NSString *userName = [self.site.metadata objectForKey:TBSiteUserNameKey];
	NSString *server = [self.site.metadata objectForKey:TBSiteServerKey];
	NSString *remotePath = [self.site.metadata objectForKey:TBSiteRemotePathKey];
	NSString *destinationArgument = [NSString stringWithFormat:@"%@@%@:%@", userName, server, remotePath];
	[arguments addObject:destinationArgument];
	
	rsync.arguments = arguments;
	
	NSMutableDictionary *environment = [NSMutableDictionary dictionary];
	
	NSURL *authenticationToolURL = [[NSBundle mainBundle] URLForResource:@"Tribo Authentication Tool" withExtension:@""];
	[environment setObject:authenticationToolURL.path forKey:@"SSH_ASKPASS"];
	[environment setObject:@"NONE" forKey:@"DISPLAY"];
	[environment setObject:@"" forKey:@"SSH_AUTH_SOCK"];
	
	NSString *appSupportDirectory = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Tribo"];
	[[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *knownHostsPath = [appSupportDirectory stringByAppendingPathComponent:@"known_hosts"];
	NSString *knownHostsOption = [NSString stringWithFormat:@"'UserKnownHostsFile \"%@\"'", knownHostsPath];
	
	if (![self passwordFromKeychain]) {
		NSURL *identityURL = [self userSelectedIdentityURL];
		if (!identityURL) {
			if (self.errorHandler) self.errorHandler(nil);
			return;
		}
		[environment setObject:[NSString stringWithFormat:@"/usr/bin/ssh -i %@ -F /dev/null -o %@", identityURL.path, knownHostsOption] forKey:@"RSYNC_RSH"];
		[environment setObject:identityURL.path forKey:@"TB_IDENTITY_PATH"];
	}
	else {
		[environment setObject:[NSString stringWithFormat:@"/usr/bin/ssh -F /dev/null -o %@", knownHostsOption] forKey:@"RSYNC_RSH"];
	}
	
	[environment addEntriesFromDictionary:self.site.metadata];
	
	rsync.environment = environment;
	
	NSFileHandle *outputFileHandle = [rsync.standardOutput fileHandleForReading];
	__block NSString *lastNewLine = @"";
	__block NSInteger lastPercentage = 0;
	NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	[outputFileHandle setReadabilityHandler:^(NSFileHandle *fileHandle) {
		
		NSString *availableOutput = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSASCIIStringEncoding];
		NSString *lastLine = [[availableOutput componentsSeparatedByCharactersInSet:newlineCharacterSet] lastObject];
		if (![lastLine isEqualToString:lastNewLine]) {
			NSArray *components = [lastLine componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
			for (NSString *component in components) {
				if (![component hasSuffix:@"%"]) continue;
				NSInteger integerValue = [component integerValue];
				if (integerValue == lastPercentage) return;
				if (self.progressHandler) self.progressHandler(integerValue, 100);
				lastPercentage = integerValue;
			}
		}
		
	}];
	
	NSFileHandle *errorFileHandle = [rsync.standardError fileHandleForReading];
	[errorFileHandle setReadabilityHandler:^(NSFileHandle *fileHandle) {
		
		NSString *availableOutput = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSASCIIStringEncoding];
		NSLog(@"stderr: %@", availableOutput);
		
	}];
	
	[rsync setTerminationHandler:^(NSTask *task) {
		if (self.completionHandler) self.completionHandler();
	}];
	
	[rsync launch];
	
}

@end
