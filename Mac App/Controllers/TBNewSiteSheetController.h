//
//  TBNewSiteSheetController.h
//  Tribo
//
//  Created by Carter Allen on 3/19/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import <Cocoa/Cocoa.h>

typedef void(^TBNewSiteSheetCompletionHandler)(NSString *name, NSString *author, NSURL *URL);

@interface TBNewSiteSheetController : NSWindowController
- (void)runModalForWindow:(NSWindow *)window completionHandler:(TBNewSiteSheetCompletionHandler)handler;
@end
