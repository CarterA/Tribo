//
//  TBAppDelegate.h
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBSite;

@interface TBAppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet NSWindow *window;
@property (strong) TBSite *site;
@end