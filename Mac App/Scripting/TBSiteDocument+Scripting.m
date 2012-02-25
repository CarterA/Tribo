//
//  TBSiteDocument+Scripting.m
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSiteDocument+Scripting.h"
#import "TBSiteWindowController.h"
#import "TBPostsViewController.h"
#import "TBSite.h"
#import "TBHTTPServer.h"

@implementation TBSiteDocument (Scripting)
- (void)startPreviewFromScript:(NSScriptCommand *)command {
	
	if (self.server.isRunning) return;
	
	[command suspendExecution];
	
	TBSiteWindowController *windowController = [self.windowControllers objectAtIndex:0];
	TBPostsViewController *postsViewController = nil;
	for (TBViewController *viewController in windowController.viewControllers) {
		if ([viewController class] == [TBPostsViewController class]) {
			postsViewController = (TBPostsViewController *)viewController;
			continue;
		}
	}
	if (!postsViewController) return;
	
	postsViewController.previewButton.hidden = YES;
	postsViewController.progressIndicator.hidden = NO;
	[postsViewController.progressIndicator startAnimation:self];
	
	[self startPreview:^(NSError *error) {
		if (error) {
			command.scriptErrorNumber = (int)error.code;
			command.scriptErrorString = error.localizedDescription;
		}
		[postsViewController.progressIndicator stopAnimation:self];
		postsViewController.progressIndicator.hidden = YES;
		postsViewController.previewButton.hidden = NO;
		postsViewController.previewButton.title = @"Stop Server";
		[postsViewController.previewButton sizeToFit];
		[command resumeExecutionWithResult:nil];
	}];
	
}
- (void)stopPreviewFromScript:(NSScriptCommand *)command {
	
	if (!self.server.isRunning) return;
	
	TBSiteWindowController *windowController = [self.windowControllers objectAtIndex:0];
	TBPostsViewController *postsViewController = nil;
	for (TBViewController *viewController in windowController.viewControllers) {
		if ([viewController class] == [TBPostsViewController class]) {
			postsViewController = (TBPostsViewController *)viewController;
			continue;
		}
	}
	if (!postsViewController) return;
	
	[self stopPreview];
	postsViewController.previewButton.title = @"Preview";
	[postsViewController.previewButton sizeToFit];
	
}
@end
