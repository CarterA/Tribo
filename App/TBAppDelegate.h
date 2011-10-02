//
//  TBAppDelegate.h
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBSite;
@class HTTPServer;

@interface TBAppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *postTableView;
@property (strong) TBSite *site;
@property (nonatomic, strong) HTTPServer *server;
@end