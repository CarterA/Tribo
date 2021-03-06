//
//  TBFTPPublisher.m
//  Tribo
//
//  Created by Carter Allen on 3/5/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBFTPPublisher.h"
#import "TBSite.h"
#import "TBMacros.h"
#import "CURLFTPSession.h"

@interface TBFTPPublisher ()
- (NSString *)passwordFromKeychain;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation TBFTPPublisher

- (void)publish {
	
	self.site.published = YES;
	[self.site process:nil];
	self.site.published = NO;
	
	NSString *hostname = (self.site.metadata)[TBSiteServerKey];
	NSString *remotePath = (self.site.metadata)[TBSiteRemotePathKey];
	NSString *userName = (self.site.metadata)[TBSiteUserNameKey];
	NSString *password = [self passwordFromKeychain];
	
	NSString *outputParent = [remotePath stringByReplacingOccurrencesOfString:[remotePath lastPathComponent] withString:@""];
	NSString *outputRoot = [outputParent stringByAppendingPathComponent:remotePath.lastPathComponent];
	
	NSURL *FTPURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@/", hostname]];
	NSURLRequest *FTPRequest = [NSURLRequest requestWithURL:FTPURL];
	NSURLCredential *FTPCredential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
	CURLFTPSession *FTPSession = [[CURLFTPSession alloc] initWithRequest:FTPRequest];
	[FTPSession useCredential:FTPCredential];
	NSNumber *permissions = @755UL;
	
	[FTPSession createDirectoryAtPath:outputRoot permissions:permissions withIntermediateDirectories:NO error:nil];
	
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.site.destination includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLNameKey] options:0 errorHandler:nil];
	NSMutableArray *directories = [NSMutableArray array]; // Array of remote paths
	NSMutableDictionary *files = [NSMutableDictionary dictionary]; // Dictionary of remote paths (keys) and local file URLs (objects)
	for (NSURL *URL in enumerator) {
		
		NSString *fileName = @"";
		[URL getResourceValue:&fileName forKey:NSURLNameKey error:nil];
		
		NSNumber *isDirectory = nil;
		[URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
		
		NSString *path = [URL path];
		NSRange localRootRange = [path rangeOfString:self.site.destination.path options:NSAnchoredSearch];
		NSString *remoteFilePath = [[outputRoot stringByAppendingString:[path substringWithRange:NSMakeRange(localRootRange.length, path.length - localRootRange.length)]] stringByStandardizingPath];
		
		if ([isDirectory boolValue]) {
			[directories addObject:remoteFilePath];
		}
		else {
			files[remoteFilePath] = URL;
		}
		
	}
	
	MAWeakSelfDeclare();
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		MAWeakSelfImport();
		NSInteger totalOperations = [directories count] + [files count];
		__block NSInteger completedOperations = 0;
		
		[directories enumerateObjectsUsingBlock:^(NSString *remoteDirectoryPath, NSUInteger index, BOOL *stop) {
			[FTPSession createDirectoryAtPath:remoteDirectoryPath permissions:permissions withIntermediateDirectories:NO error:nil];
			completedOperations++;
			if (self.progressHandler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.progressHandler(completedOperations, totalOperations);
				});
			}
		}];
		[files enumerateKeysAndObjectsUsingBlock:^(NSString *remoteFilePath, NSURL *localFileURL, BOOL *stop) {
			MAWeakSelfImport();
			NSData *fileContents = [NSData dataWithContentsOfURL:localFileURL];
			[FTPSession createFileAtPath:remoteFilePath contents:fileContents permissions:permissions withIntermediateDirectories:NO error:nil];
			completedOperations++;
			if (self.progressHandler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.progressHandler(completedOperations, totalOperations);
				});
			}
		}];
		
		if (self.completionHandler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				MAWeakSelfImport();
				self.completionHandler();
			});
		}
	});
	
}

- (NSString *)passwordFromKeychain {
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = (self.site.metadata)[TBSiteServerKey];
	NSString *accountName = (self.site.metadata)[TBSiteUserNameKey];
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[(self.site.metadata)[TBSitePortKey] integerValue];
	SecProtocolType protocol = kSecProtocolTypeFTP;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, "", port, protocol, kSecAuthenticationTypeDefault, &passwordLength, (void **)&passwordBuffer, NULL);
	if (returnStatus != noErr)
		return nil;
	NSString *password = [[NSString alloc] initWithBytes:passwordBuffer length:passwordLength encoding: NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordBuffer);
	if ([password length] == 0) password = nil;
	return password;
}

@end
