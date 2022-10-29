//
//  TBCloudflarePublisher.m
//  Tribo
//
//  Created by Carter Allen on 10/27/22.
//  Copyright (c) 2022 The Tribo Authors.
//  See the included License.md file.
//
//  This class implementation was heavily inspired by @adamburgess's
//  "cloudflare-pages-direct-uploader" project. Thank you Adam for doing
//  the hard work of reverse-engineering the Cloudflare Pages API.
//

#import "TBCloudflarePublisher.h"
#import "TBSite.h"
#import "TBMacros.h"
#import "blake3.h"

@interface TBCloudflarePublisher ()
- (NSString *)tokenFromKeychain;
- (id)sendAPIRequestToEndPoint:(NSString *)endPoint withToken:(NSString *)token body:(NSData *)body overrideContentType:(NSString *)contentType;
@end

@implementation TBCloudflarePublisher

- (void)publish {
	
	self.site.published = YES;
	[self.site process:nil];
	self.site.published = NO;
	
	NSString *hostname = (self.site.metadata)[TBSiteServerKey];
	NSString *userName = (self.site.metadata)[TBSiteUserNameKey];
	
	NSDictionary *uploadTokenResponse = [self sendAPIRequestToEndPoint:[NSString stringWithFormat:@"accounts/%@/pages/projects/%@/upload-token", userName, hostname] withToken:[self tokenFromKeychain] body:nil overrideContentType:nil];
	NSString *uploadToken = uploadTokenResponse[@"jwt"];
			
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.site.destination includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLNameKey] options:0 errorHandler:nil];
	NSMutableDictionary *relPaths = [NSMutableDictionary dictionary];
	NSMutableDictionary *b64Data = [NSMutableDictionary dictionary];
	NSMutableDictionary *mimeTypes = [NSMutableDictionary dictionary];
	NSMutableDictionary *manifest = [NSMutableDictionary dictionary];
	dispatch_group_t group = dispatch_group_create();
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
	for (NSURL *URL in enumerator) {
		
		NSNumber *isDirectory = nil;
		[URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
		
		if ([isDirectory boolValue])
			continue;
			
		
		NSString *fileName = @"";
		[URL getResourceValue:&fileName forKey:NSURLNameKey error:nil];
		
		NSURLRequest *localFileRequest = [NSURLRequest requestWithURL:URL];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:localFileRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			NSString *fileB64 = [data base64EncodedStringWithOptions:0];
			NSString *hashInput = [fileB64 stringByAppendingString:URL.pathExtension];
			
			blake3_hasher hasher;
			blake3_hasher_init(&hasher);
			blake3_hasher_update(&hasher, hashInput.UTF8String, [hashInput lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
			uint8_t output[BLAKE3_OUT_LEN];
			blake3_hasher_finalize(&hasher, output, BLAKE3_OUT_LEN);
			NSMutableString *fullHash = [NSMutableString string];
			for (size_t i = 0; i < BLAKE3_OUT_LEN; i++) {
				[fullHash appendFormat:@"%02x", output[i]];
			}
			NSString *truncatedHash = [fullHash substringToIndex:32];
			relPaths[truncatedHash] = [URL.path stringByReplacingOccurrencesOfString:self.site.destination.path withString:@""];;
			b64Data[truncatedHash] = fileB64;
			mimeTypes[truncatedHash] = response.MIMEType;
			manifest[relPaths[truncatedHash]] = truncatedHash;
			dispatch_group_leave(group);
		}];
		dispatch_group_enter(group);
		[dataTask resume];
				
	}
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	NSData *missingHashBody = [NSJSONSerialization dataWithJSONObject:@{ @"hashes": relPaths.allKeys } options:0 error:nil];
	NSArray *missingHashResponse = [self sendAPIRequestToEndPoint:[NSString stringWithFormat:@"pages/assets/check-missing"] withToken:uploadToken body:missingHashBody overrideContentType:nil];
	for (NSString *missingHash in missingHashResponse) {
		NSLog(@"Hash %@ was missing (path = %@), uploading", missingHash, relPaths[missingHash]);
		NSData *uploadBody = [NSJSONSerialization dataWithJSONObject:@[@{
			@"key": missingHash,
			@"value": b64Data[missingHash],
			@"metadata": @{
				@"contentType": mimeTypes[missingHash]
			},
			@"base64": [NSNumber numberWithBool:YES]
		}] options:0 error:nil];
//		NSString *uploadBodyString = [[NSString alloc] initWithData:uploadBody encoding:NSUTF8StringEncoding];
		id uploadResult = [self sendAPIRequestToEndPoint:@"pages/assets/upload" withToken:uploadToken body:uploadBody overrideContentType:nil];
		NSLog(@"Upload complete (%@)", uploadResult);
	}
	NSData *upsertBody = [NSJSONSerialization dataWithJSONObject:@{ @"hashes": missingHashResponse } options:0 error:nil];
	id upsertResult = [self sendAPIRequestToEndPoint:@"pages/assets/upsert-hashes" withToken:uploadToken body:upsertBody overrideContentType:nil];
	NSLog(@"Upsert result: %@", upsertResult);
	
	NSString *boundary = @"BOUNDARY_2549536629329";
	NSMutableData *deployBody = [NSMutableData data];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];

	[deployBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[deployBody appendData:[@"Content-Disposition: form-data; name=\"manifest\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[deployBody appendData:[NSJSONSerialization dataWithJSONObject:manifest options:0 error:nil]];
	[deployBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	id deployResult = [self sendAPIRequestToEndPoint:[NSString stringWithFormat:@"accounts/%@/pages/projects/%@/deployments", userName, hostname] withToken:[self tokenFromKeychain] body:deployBody overrideContentType:contentType];
	NSLog(@"Deployment result: %@", deployResult);
	
	if (self.completionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.completionHandler();
		});
	}
	
}

- (id)sendAPIRequestToEndPoint:(NSString *)endPoint withToken:(NSString *)token body:(NSData *)body overrideContentType:(NSString *)contentType {
	NSURL *baseURL = [NSURL URLWithString:@"https://api.cloudflare.com/client/v4/"];
	NSURL *endpointURL = [NSURL URLWithString:endPoint relativeToURL:baseURL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpointURL];
	[request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
	[request addValue:@"@CarterA/Tribo" forHTTPHeaderField:@"User-Agent"];
	if (contentType)
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	else
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	if (body) {
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:body];
	}
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	NSLog(@"endpoint = %@, responseDict = %@", endPoint, responseDict);
	return responseDict[@"result"];
}

- (NSString *)tokenFromKeychain {
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = [(self.site.metadata)[TBSiteServerKey] stringByAppendingString:@".pages.dev"];
	NSString *accountName = (self.site.metadata)[TBSiteUserNameKey];
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[(self.site.metadata)[TBSitePortKey] integerValue];
	SecProtocolType protocol = kSecProtocolTypeHTTPS;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, "", port, protocol, kSecAuthenticationTypeDefault, &passwordLength, (void **)&passwordBuffer, NULL);
	if (returnStatus != noErr)
		return nil;
	NSString *password = [[NSString alloc] initWithBytes:passwordBuffer length:passwordLength encoding: NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordBuffer);
	if ([password length] == 0) password = nil;
	return password;
}

@end
