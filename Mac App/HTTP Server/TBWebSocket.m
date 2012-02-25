//
//  TBWebSocket.m
//  Tribo
//
//  Created by Carter Allen on 2/24/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBWebSocket.h"

@implementation TBWebSocket

- (void)didOpen {
	NSLog(@"didOpen");
	NSString *helloMessage = @"{ \"command\": \"hello\", \"protocols\": [\"http://livereload.com/protocols/official-7\", \"http://livereload.com/protocols/official-8\", \"http://livereload.com/protocols/2.x-origin-version-negotiation\"], \"serverName\": \"Tribo\" }";
	[self sendMessage:helloMessage];
}

- (void)didReceiveMessage:(NSString *)message {
	
}

- (void)didClose {
	
}

@end
