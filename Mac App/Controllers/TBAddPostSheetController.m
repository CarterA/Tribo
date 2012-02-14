//
//  TBAddPostSheetController.m
//  Tribo
//
//  Created by Carter Allen on 10/7/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBAddPostSheetController.h"

@interface TBAddPostSheetController ()
@property (nonatomic, copy) TBAddPostSheetControllerCompletionHandler completionHandler;
@property (nonatomic, assign) IBOutlet NSTextField *titleField;
@property (nonatomic, assign) IBOutlet NSTextField *slugField;
@property (nonatomic, assign) IBOutlet NSButton *addButton;
- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation TBAddPostSheetController
@synthesize titleField=_titleField;
@synthesize slugField=_slugField;
@synthesize addButton=_addButton;
@synthesize completionHandler=_completionHandler;

- (id)init {
	self = [super initWithWindowNibName:@"TBAddPostSheet"];
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)runModalForWindow:(NSWindow *)window completionBlock:(TBAddPostSheetControllerCompletionHandler)completionHandler {
	self.completionHandler = completionHandler;
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)cancel:(id)sender {
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (IBAction)add:(id)sender {
	[NSApp endSheet:self.window returnCode:NSOKButton];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	NSString *slug = self.slugField.stringValue;
	if (!slug || [slug isEqualToString:@""]) slug = [self.slugField.cell placeholderString];
	if (returnCode == NSOKButton && self.completionHandler)
		self.completionHandler(self.titleField.stringValue, slug);
	[self.window orderOut:self];
}

- (void)controlTextDidChange:(NSNotification *)notification {
	NSTextField *field = (NSTextField *)[(NSTextView *)self.window.firstResponder delegate];
	if (field != self.titleField) return;
	
	if (!field.stringValue || [field.stringValue isEqualToString:@""]) {
		self.addButton.enabled = NO;
		[self.slugField.cell setPlaceholderString:@""];
		return;
	}
	
	NSString *title = field.stringValue;
	NSMutableString *slug = [NSMutableString string];
	NSMutableCharacterSet *validCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
	[validCharacterSet addCharactersInString:@"-"];
	[title enumerateSubstringsInRange:NSMakeRange(0, title.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if ([validCharacterSet characterIsMember:[substring characterAtIndex:0]])
			[slug appendString:[substring lowercaseString]];
		else if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[substring characterAtIndex:0]])
			[slug appendString:@"-"];
	}];
	[self.slugField.cell setPlaceholderString:slug];
	self.addButton.enabled = YES;
	
}

@end