//
//  TBPublishSheetController.m
//  Tribo
//
//  Created by Carter Allen on 2/29/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPublishSheetController.h"
#import "TBPublisher.h"

@interface TBPublishSheetController ()
@property (nonatomic, assign) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, strong) TBPublisher *publisher;
@end

@implementation TBPublishSheetController
@synthesize site = _site;
@synthesize indicator = _indicator;
@synthesize publisher = _publisher;

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
	
	[self.publisher setProgressHandler:^(NSInteger progress, NSInteger total) {
		self.indicator.indeterminate = NO;
		self.indicator.doubleValue = ((double)progress/(double)total) * 100.0;
	}];
	
	[self.publisher setCompletionHandler:^() {
		self.indicator.doubleValue = 100;
		[NSApp endSheet:self.window];
		[self.window orderOut:nil];
	}];
	
	[self.publisher setErrorHandler:^(NSError *error) {
		[NSApp endSheet:self.window];
		[self.window orderOut:nil];
	}];
	
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	
	[self.publisher publish];
	
}

@end
