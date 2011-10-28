//
//  TBSiteWindowController.m
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSiteWindowController.h"
#import "TBViewController.h"
#import "TBPostsViewController.h"

@implementation TBSiteWindowController
@synthesize viewControllers=_viewControllers;
@synthesize selectedViewControllerIndex=_selectedViewControllerIndex;

- (id)init {
	self = [super initWithWindowNibName:@"TBSiteWindow"];
	return self;
}

#pragma mark - View Controller Management

- (TBViewController *)selectedViewController {
	return [self.viewControllers objectAtIndex:self.selectedViewControllerIndex];
}

- (void)setSelectedViewControllerIndex:(NSUInteger)selectedViewControllerIndex {
	_selectedViewControllerIndex = selectedViewControllerIndex;
	self.window.contentView = [[self.viewControllers objectAtIndex:_selectedViewControllerIndex] view];
}

#pragma mark - Window Delegate Methods

- (void)windowDidLoad {
	[super windowDidLoad];
	
	TBPostsViewController *postsViewController = [TBPostsViewController new];
	postsViewController.document = self.document;
	self.viewControllers = [NSArray arrayWithObjects:postsViewController, nil];
	self.selectedViewControllerIndex = 0;
	
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	//self.postCountLabel.textColor = [NSColor controlTextColor];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	//self.postCountLabel.textColor = [NSColor disabledControlTextColor];
}

@end