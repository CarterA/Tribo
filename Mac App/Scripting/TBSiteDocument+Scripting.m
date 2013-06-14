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
	
	TBSiteWindowController *windowController = (self.windowControllers)[0];
	TBPostsViewController *postsViewController = nil;
	for (TBViewController *viewController in windowController.viewControllers) {
		if ([viewController class] == [TBPostsViewController class]) {
			postsViewController = (TBPostsViewController *)viewController;
			continue;
		}
	}
	if (!postsViewController) return;
	
	[self startPreview:^(NSURL *localURL, NSError *error) {
		if (error) {
			command.scriptErrorNumber = (int)error.code;
			command.scriptErrorString = error.localizedDescription;
		}
		[command resumeExecutionWithResult:nil];
	}];
	
}
- (void)stopPreviewFromScript:(NSScriptCommand *)command {
	
	if (!self.server.isRunning) return;
	
	TBSiteWindowController *windowController = (self.windowControllers)[0];
	TBPostsViewController *postsViewController = nil;
	for (TBViewController *viewController in windowController.viewControllers) {
		if ([viewController class] == [TBPostsViewController class]) {
			postsViewController = (TBPostsViewController *)viewController;
			continue;
		}
	}
	if (!postsViewController) return;
	
	[self stopPreview];
	
}
@end
