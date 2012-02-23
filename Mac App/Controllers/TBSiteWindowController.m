//
//  TBSiteWindowController.m
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSiteWindowController.h"
#import "TBViewController.h"
#import "TBPostsViewController.h"
#import "TBTemplatesViewController.h"
#import "TBSourceViewControllerViewController.h"
#import "TBTabView.h"
#import <QuartzCore/QuartzCore.h>

@interface TBSiteWindowController () <TBTabViewDelegate>
@property (nonatomic, assign) IBOutlet TBTabView *tabView;
@property (nonatomic, assign) IBOutlet NSView *containerView;
@property (nonatomic, assign) NSView *currentView;
@end

@implementation TBSiteWindowController
@synthesize viewControllers=_viewControllers;
@synthesize selectedViewControllerIndex=_selectedViewControllerIndex;
@synthesize tabView=_tabView;
@synthesize containerView=_containerView;
@synthesize currentView=_currentView;

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
	NSView *newView = [[self.viewControllers objectAtIndex:_selectedViewControllerIndex] view];
	if (self.currentView == newView)
		return;
	if (self.currentView)
		[self.currentView removeFromSuperview];
	newView.frame = self.containerView.bounds;
	newView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
	[self.containerView addSubview:newView];
	self.currentView = newView;
}

- (void)setViewControllers:(NSArray *)viewControllers {
	_viewControllers = viewControllers;
	self.tabView.titles = [self.viewControllers valueForKey:@"title"];
	self.tabView.selectedIndex = self.selectedViewControllerIndex;
}

#pragma mark - Tab View Delegate Methods

- (void)tabView:(TBTabView *)tabView didSelectIndex:(NSUInteger)index {
	self.selectedViewControllerIndex = index;
}

#pragma mark - Window Delegate Methods

- (void)windowDidLoad {
	[super windowDidLoad];
	
	TBPostsViewController *postsViewController = [TBPostsViewController new];
	postsViewController.document = self.document;
	
	TBTemplatesViewController *templatesController = [TBTemplatesViewController new];
    templatesController.document = self.document;
    
    TBSourceViewControllerViewController *sourcesController = [TBSourceViewControllerViewController new];
    sourcesController.document = self.document;
	
	self.viewControllers = [NSArray arrayWithObjects:postsViewController, templatesController, sourcesController, nil];
	self.selectedViewControllerIndex = 0;
	
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	//self.postCountLabel.textColor = [NSColor controlTextColor];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	//self.postCountLabel.textColor = [NSColor disabledControlTextColor];
}

@end
