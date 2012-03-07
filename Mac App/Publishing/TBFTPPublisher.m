//
//  TBFTPPublisher.m
//  Tribo
//
//  Created by Carter Allen on 3/5/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBFTPPublisher.h"
#import "TBSite.h"
#import "CURLFTPSession.h"

@interface TBFTPPublisher () <CURLFTPSessionDelegate>
- (NSString *)passwordFromKeychain;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation TBFTPPublisher
@synthesize data = _data;

- (void)publish {
	
	[self.site process:nil];
	
	NSString *hostname = [self.site.metadata objectForKey:TBSiteServerKey];
	NSString *remotePath = [self.site.metadata objectForKey:TBSiteRemotePathKey];
	NSString *userName = [self.site.metadata objectForKey:TBSiteUserNameKey];
	NSString *password = [self passwordFromKeychain];
	
	NSString *outputParent = [remotePath stringByReplacingOccurrencesOfString:[remotePath lastPathComponent] withString:@""];
	NSString *outputRoot = [outputParent stringByAppendingPathComponent:remotePath.lastPathComponent];
	
	NSURL *FTPURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@/", hostname]];
	NSURLRequest *FTPRequest = [NSURLRequest requestWithURL:FTPURL];
	NSURLCredential *FTPCredential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
	CURLFTPSession *FTPSession = [[CURLFTPSession alloc] initWithRequest:FTPRequest];
	FTPSession.delegate = self;
	[FTPSession useCredential:FTPCredential];
	
	[FTPSession createDirectoryAtPath:outputRoot permissions:[NSNumber numberWithUnsignedLong:755] withIntermediateDirectories:NO error:nil];
	
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.site.destination includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLNameKey, nil] options:0 errorHandler:nil];
	for (NSURL *URL in enumerator) {
		
		NSString *fileName = @"";
		[URL getResourceValue:&fileName forKey:NSURLNameKey error:nil];
		
		NSNumber *isDirectory = nil;
		[URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
		
		NSString *path = [URL path];
		NSRange localRootRange = [path rangeOfString:self.site.destination.path options:NSAnchoredSearch];
		NSString *remoteFilePath = [[outputRoot stringByAppendingString:[path substringWithRange:NSMakeRange(localRootRange.length, path.length - localRootRange.length)]] stringByStandardizingPath];
		
		if ([isDirectory boolValue]) {
			[FTPSession createDirectoryAtPath:remoteFilePath permissions:[NSNumber numberWithUnsignedLong:755] withIntermediateDirectories:NO error:nil];
		}
		else {
			NSData *fileContents = [NSData dataWithContentsOfURL:URL];
			[FTPSession createFileAtPath:remoteFilePath contents:fileContents permissions:[NSNumber numberWithUnsignedLong:755] withIntermediateDirectories:NO error:nil];
		}
		
	}
	
}

- (void)FTPSession:(CURLFTPSession *)session didReceiveDebugInfo:(NSString *)info ofType:(curl_infotype)type {
}

- (NSString *)passwordFromKeychain {
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = [self.site.metadata objectForKey:TBSiteServerKey];
	NSString *accountName = [self.site.metadata objectForKey:TBSiteUserNameKey];
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[[self.site.metadata objectForKey:TBSitePortKey] integerValue];
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
