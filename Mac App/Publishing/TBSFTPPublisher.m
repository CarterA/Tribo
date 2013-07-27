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

NSString * const TBSFTPPublisherIdentityBookmarkKey = @"TBSFTPPublisherIdentityBookmark";

@interface TBSFTPPublisher ()
- (NSURL *)userSelectedIdentityURL;
- (NSString *)passwordFromKeychain;
@property (nonatomic, strong) NSURL *identityURL;
@end

@implementation TBSFTPPublisher

- (NSURL *)userSelectedIdentityURL {
	
	NSData *bookmarkData = [[NSUserDefaults standardUserDefaults] dataForKey:TBSFTPPublisherIdentityBookmarkKey];
	NSURL *identityURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:NULL error:nil];
	if (identityURL) {
		return identityURL;
	}
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.message = @"Please select the SSH identity file (usually called id_rsa or ida_dsa) that should be used to authenticate with the server. Identity files are typically found in the .ssh folder in your home directory.";
	panel.directoryURL = [[NSURL fileURLWithPath:NSHomeDirectory()] URLByAppendingPathComponent:@".ssh" isDirectory:YES];
	panel.showsHiddenFiles = YES;
	panel.allowsMultipleSelection = YES;
	NSInteger button = [panel runModal];
	
	if (button == NSFileHandlingPanelCancelButton) return nil;
	
	identityURL = [panel URLs][0];
	bookmarkData = [identityURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope|NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
	[[NSUserDefaults standardUserDefaults] setObject:bookmarkData forKey:TBSFTPPublisherIdentityBookmarkKey];
	
	return identityURL;
	
}

- (NSString *)passwordFromKeychain {
	
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = (self.site.metadata)[TBSiteServerKey];
	NSString *accountName = (self.site.metadata)[TBSiteUserNameKey];
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[(self.site.metadata)[TBSitePortKey] integerValue];
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
	
	NSString *userName = (self.site.metadata)[TBSiteUserNameKey];
	NSString *server = (self.site.metadata)[TBSiteServerKey];
	NSString *remotePath = (self.site.metadata)[TBSiteRemotePathKey];
	NSString *destinationArgument = [NSString stringWithFormat:@"%@@%@:%@", userName, server, remotePath];
	[arguments addObject:destinationArgument];
	
	rsync.arguments = arguments;
	
	NSMutableDictionary *environment = [NSMutableDictionary dictionary];
	
	NSURL *authenticationToolURL = [[NSBundle mainBundle] URLForResource:@"Tribo Authentication Tool" withExtension:@""];
	environment[@"SSH_ASKPASS"] = authenticationToolURL.path;
	environment[@"DISPLAY"] = @"NONE";
	environment[@"SSH_AUTH_SOCK"] = @"";
	
	NSString *appSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Tribo"];
	[[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *knownHostsPath = [appSupportDirectory stringByAppendingPathComponent:@"known_hosts"];
	NSString *knownHostsOption = [NSString stringWithFormat:@"'UserKnownHostsFile \"%@\"'", knownHostsPath];
	
	if (![self passwordFromKeychain]) {
		self.identityURL = [self userSelectedIdentityURL];
		if (!self.identityURL) {
			if (self.errorHandler) self.errorHandler(nil);
			return;
		}
		[self.identityURL startAccessingSecurityScopedResource];
		environment[@"RSYNC_RSH"] = [NSString stringWithFormat:@"/usr/bin/ssh -i %@ -F /dev/null -o %@", self.identityURL.path, knownHostsOption];
		environment[TBSiteIdentityFileEnvironmentKey] = self.identityURL.path;
	}
	else {
		environment[@"RSYNC_RSH"] = [NSString stringWithFormat:@"/usr/bin/ssh -F /dev/null -o %@", knownHostsOption];
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
		if (self.identityURL) [self.identityURL stopAccessingSecurityScopedResource];
		if (self.completionHandler) self.completionHandler();
	}];
	
	[rsync launch];
	
}

@end
