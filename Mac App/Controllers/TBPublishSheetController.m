//
//  TBPublishSheetController.m
//  Tribo
//
//  Created by Carter Allen on 2/29/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPublishSheetController.h"
#import "TBPublisher.h"

@interface TBPublishSheetController ()
@property (nonatomic, assign) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, strong) TBPublisher *publisher;
@end

@implementation TBPublishSheetController

- (id)init {
	self = [super initWithWindowNibName:@"TBPublishSheet"];
	return self;
}

- (void)runModalForWindow:(NSWindow *)window site:(TBSite *)site {
	
	[self loadWindow];
	self.site = site;
	self.indicator.doubleValue = 0.0;
	self.indicator.indeterminate = YES;
	[self.indicator startAnimation:nil];
	
	self.publisher = [TBPublisher publisherWithSite:site];
	
	__weak TBPublishSheetController *weakSelf = self;
	
	[self.publisher setProgressHandler:^(NSInteger progress, NSInteger total) {
		weakSelf.indicator.indeterminate = NO;
		weakSelf.indicator.doubleValue = ((double)progress/(double)total) * 100.0;
	}];
	
	[self.publisher setCompletionHandler:^() {
		weakSelf.indicator.doubleValue = 100;
		[NSApp endSheet:weakSelf.window];
		[weakSelf.window orderOut:nil];
	}];
	
	[self.publisher setErrorHandler:^(NSError *error) {
		[NSApp endSheet:weakSelf.window];
		[weakSelf.window orderOut:nil];
	}];
	
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	
	[self.publisher publish];
	
}

@end
