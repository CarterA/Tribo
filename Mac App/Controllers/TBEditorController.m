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

@interface TBEditorController ()
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
	//[self.textView.textStorage replaceCharactersInRange:NSMakeRange(0, self.textView.textStorage.length) withString:fileContents];
	self.textView.string = fileContents;
}

- (void)viewDidLoad {
	[self.textView.layoutManager replaceTextStorage:[TBEditorStorage new]];
	self.textView.textContainerInset = NSMakeSize(25.0, 25.0);
	self.textView.font = [NSFont fontWithName:@"Avenir Next" size:14.0];
}

@end
