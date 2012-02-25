//
//  TBHTTPServer.m
//  Tribo
//
//  Created by Carter Allen on 2/24/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBHTTPServer.h"
#import "TBWebSocket.h"

@implementation TBHTTPServer
- (void)refreshPages {
	for (TBWebSocket *webSocket in webSockets) {
		[webSocket sendMessage:@"{ \"command\": \"reload\", \"path\": \"/\", \"liveCSS\": true }"];
	}
}
@end
