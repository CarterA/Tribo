//
//  TBSocketConnection.m
//  Tribo
//
//  Created by Carter Allen on 2/24/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSocketConnection.h"
#import "TBWebSocket.h"
#import "HTTPAsyncFileResponse.h"

@interface TBSocketConnection () <WebSocketDelegate>
@property (nonatomic, strong) WebSocket *socket;
@end

@implementation TBSocketConnection
@synthesize socket = _socket;

- (WebSocket *)webSocketForURI:(NSString *)path {
	if ([path isEqualToString:@"/livereload"]) {
		self.socket = [[TBWebSocket alloc] initWithRequest:request socket:asyncSocket];
		return self.socket;
	}
	return [super webSocketForURI:path];
}

- (NSObject <HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	
	if ([path hasPrefix:@"/livereload.js"]) {
		NSURL *livereloadURL = [[NSBundle mainBundle] URLForResource:@"livereload" withExtension:@"js"];
		return [[HTTPAsyncFileResponse alloc] initWithFilePath:livereloadURL.path forConnection:self];
	}
	
	return [super httpResponseForMethod:method URI:path];
	
}

@end
