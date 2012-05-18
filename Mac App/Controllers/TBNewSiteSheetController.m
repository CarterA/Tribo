//
//  TBNewSiteSheetController.m
//  Tribo
//
//  Created by Carter Allen on 3/19/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBNewSiteSheetController.h"

@interface TBNewSiteSheetController ()
@property (nonatomic, copy) TBNewSiteSheetCompletionHandler handler;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation TBNewSiteSheetController
@synthesize handler = _handler;

- (id)init {
    self = [super initWithWindowNibName:@"TBNewSiteSheet"];
    return self;
}

- (void)runModalForWindow:(NSWindow *)window completionHandler:(TBNewSiteSheetCompletionHandler)handler {
	self.handler = handler;
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
}

@end
