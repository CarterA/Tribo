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
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSTextField *authorField;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)next:(id)sender;
- (IBAction)cancel:(id)sender;
@end

@implementation TBNewSiteSheetController

- (id)init {
    self = [super initWithWindowNibName:@"TBNewSiteSheet"];
    return self;
}

- (void)runModalForWindow:(NSWindow *)window completionHandler:(TBNewSiteSheetCompletionHandler)handler {
	self.handler = handler;
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)next:(id)sender {
	
	NSString *name = self.nameField.stringValue;
	NSString *author = self.authorField.stringValue;
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.extensionHidden = YES;
	savePanel.nameFieldStringValue = [name stringByAppendingString:@".tribo"];
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelCancelButton) return;
		if (self.handler) self.handler(name, author, savePanel.URL);
		[NSApp endSheet:self.window returnCode:NSOKButton];
	}];
	
}

- (IBAction)cancel:(id)sender {
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (self.handler) {
		if (returnCode == NSCancelButton) {
			self.handler(nil, nil, nil);
		}
	}
	[sheet orderOut:self];
}

@end
