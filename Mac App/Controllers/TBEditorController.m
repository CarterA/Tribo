//
//  TBEditorController.m
//  Tribo
//
//  Created by Carter Allen on 7/1/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBEditorController.h"
#import "TBEditorStorage.h"

@interface TBEditorController () <NSTextViewDelegate>
@property (nonatomic, assign) IBOutlet NSTextView *textView;
@end

@implementation TBEditorController

- (NSString *)defaultNibName {
	return @"TBEditor";
}

- (void)setCurrentFile:(NSURL *)currentFile {
	if (_currentFile == currentFile) return;
	_currentFile = currentFile;
	NSString *fileContents = [NSString stringWithContentsOfURL:currentFile encoding:NSUTF8StringEncoding error:nil];
	TBEditorStorage *newStorage = [[TBEditorStorage alloc] init];
	[newStorage replaceCharactersInRange:NSMakeRange(0, 0) withString:fileContents];
	[self.textView.layoutManager replaceTextStorage:newStorage];
}

- (void)viewDidLoad {
	[self.textView.layoutManager replaceTextStorage:[TBEditorStorage new]];
	self.textView.textContainerInset = NSMakeSize(25.0, 25.0);
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
	NSRange selection = self.textView.selectedRange;
	if (selection.location == NSNotFound || selection.length == 0) return YES;
	NSDictionary *boundingCharacters = @{ @"*": @"*", @"_": @"_", @"[": @"]", @"(": @")", @"\"": @"\""};
	if (!boundingCharacters[replacementString]) return YES;
	[self.textView.undoManager beginUndoGrouping];
	NSString *selectedString = [self.textView.string substringWithRange:selection];
	NSString *boundedString = [NSString stringWithFormat:@"%@%@%@", replacementString, selectedString, boundingCharacters[replacementString]];
	[self.textView replaceCharactersInRange:selection withString:boundedString];
	NSRange replacedRange = NSMakeRange(selection.location, selection.length + 2);
	self.textView.selectedRange = replacedRange;
	[[self.textView.undoManager prepareWithInvocationTarget:self.textView] replaceCharactersInRange:replacedRange withString:selectedString];
	[self.textView.undoManager endUndoGrouping];
	return NO;
}

@end
