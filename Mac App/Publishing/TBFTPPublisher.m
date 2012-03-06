//
//  TBFTPPublisher.m
//  Tribo
//
//  Created by Carter Allen on 3/5/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBFTPPublisher.h"
#import "TBSite.h"
#import "ACFTPClient.h"

@interface TBFTPPublisher () <ACFTPClientDelegate> {
	NSUInteger requests;
}
- (NSString *)passwordFromKeychain;
@end

@implementation TBFTPPublisher

- (void)publish {
	
	[self.site process:nil];
	
	NSString *hostname = [self.site.metadata objectForKey:TBSiteServerKey];
	NSString *remotePath = [self.site.metadata objectForKey:TBSiteRemotePathKey];
	NSString *userName = [self.site.metadata objectForKey:TBSiteUserNameKey];
	NSString *password = [self passwordFromKeychain];
	
	NSString *outputParent = [remotePath stringByReplacingOccurrencesOfString:[remotePath lastPathComponent] withString:@""];
	NSString *outputRoot = [outputParent stringByAppendingPathComponent:remotePath.lastPathComponent];
	ACFTPLocation *location = [ACFTPLocation locationWithHost:hostname href:outputParent username:userName password:password];
	ACFTPClient *client = [ACFTPClient clientWithLocation:location];
	client.delegate = self;
	requests = 0;
	
	NSURL *localURL = self.site.destination;
	requests += 2;
	[client makeDirectory:remotePath.lastPathComponent inParentDirectory:outputParent];
	 
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:localURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLNameKey, nil] options:0 errorHandler:nil];
	for (NSURL *URL in enumerator) {
		
		NSString *fileName = @"";
		[URL getResourceValue:&fileName forKey:NSURLNameKey error:nil];
		
		NSNumber *isDirectory = nil;
		[URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
		
		NSString *path = [URL path];
		NSRange localRootRange = [path rangeOfString:localURL.path options:NSAnchoredSearch];
		NSString *relativeLocalPath = [path substringWithRange:NSMakeRange(localRootRange.length, path.length - localRootRange.length)];
		
		if ([isDirectory boolValue]) {
			requests++;
			[client makeDirectory:relativeLocalPath inParentDirectory:outputRoot];
		}
		else {
			requests++;
			NSString *remoteFilePath = [outputRoot stringByAppendingPathComponent:relativeLocalPath];
			NSString *remoteParentDirectory = [remoteFilePath stringByReplacingOccurrencesOfString:remoteFilePath.lastPathComponent withString:@""];
			[client put:path toDestination:remoteParentDirectory];
		}
		
	}
	requests--;
	
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

- (void)client:(ACFTPClient *)client request:(id)request didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
	requests--;
	if (self.completionHandler && requests == 0) self.completionHandler();
}

- (void)client:(ACFTPClient *)client request:(id)request didUpdateStatus:(NSString *)status {
	//NSLog(@"%@", status);
}

- (void)client:(ACFTPClient *)client request:(id)request didUpdateProgress:(float)progress {
	//NSLog(@"%f", progress);
}

- (void)client:(ACFTPClient *)client request:(id)request didUploadFile:(NSString *)sourcePath toDestination:(NSURL *)destination {
	requests--;
	if (self.completionHandler && requests == 0) self.completionHandler();
}

- (void)client:(ACFTPClient *)client request:(id)request didMakeDirectory:(NSURL *)destination {
	requests--;
	if (self.completionHandler && requests == 0) self.completionHandler();
}

@end
