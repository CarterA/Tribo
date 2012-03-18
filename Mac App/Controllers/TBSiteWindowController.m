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
#import "TBSettingsSheetController.h"
#import "TBPublishSheetController.h"
#import "TBStatusViewController.h"
#import "TBTabView.h"
#import "TBSiteDocument.h"
#import "TBHTTPServer.h"
#import <QuartzCore/QuartzCore.h>

const NSEdgeInsets TBAccessoryViewInsets = {
	.top = 0.0,
	.right = 4.0
};

@interface TBSiteWindowController () <TBTabViewDelegate>
@property (nonatomic, assign) IBOutlet NSView *accessoryView;
@property (nonatomic, assign) IBOutlet NSMenu *actionMenu;
@property (nonatomic, assign) IBOutlet TBTabView *tabView;
@property (nonatomic, assign) IBOutlet NSView *containerView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (nonatomic, assign) NSView *currentView;
@property (nonatomic, strong) TBSettingsSheetController *settingsSheetController;
@property (nonatomic, strong) TBPublishSheetController *publishSheetController;
@property (nonatomic, strong) TBStatusViewController *statusViewController;
- (void)toggleStatusView;
@end

@implementation TBSiteWindowController
@synthesize viewControllers=_viewControllers;
@synthesize selectedViewControllerIndex=_selectedViewControllerIndex;
@synthesize accessoryView=_accessoryView;
@synthesize actionMenu=_actionMenu;
@synthesize tabView=_tabView;
@synthesize containerView=_containerView;
@synthesize containerViewBottomConstraint=_containerViewBottomConstraint;
@synthesize currentView=_currentView;
@synthesize settingsSheetController=_settingsSheetController;
@synthesize publishSheetController=_publishSheetController;
@synthesize statusViewController=_statusViewController;

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

- (IBAction)switchToPosts:(id)sender {
    self.tabView.selectedIndex = 0;
}

- (IBAction)switchToTemplates:(id)sender {
    self.tabView.selectedIndex = 1;
}

- (IBAction)switchToSources:(id)sender {
    self.tabView.selectedIndex = 2;
}

- (IBAction)showActionMenu:(id)sender {
	NSPoint clickedPoint = [[NSApp currentEvent] locationInWindow];
	NSEvent *event = [NSEvent mouseEventWithType:NSRightMouseDown location:clickedPoint modifierFlags:0 timestamp:0.0 windowNumber:[self.window windowNumber] context:[NSGraphicsContext currentContext] eventNumber:1 clickCount:1 pressure:0.0];
	[NSMenu popUpContextMenu:self.actionMenu withEvent:event forView:self.accessoryView];
}

- (IBAction)preview:(id)sender {
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	NSMenuItem *previewMenuItem = (NSMenuItem *)sender;
	if (!document.server.isRunning) {
		
		[self toggleStatusView];
		self.statusViewController.title = @"Starting local preview...";
		[document startPreview:^(NSURL *localURL, NSError *error) {
			
			if (error)
				[self presentError:error];
			previewMenuItem.title = @"Stop Preview";
			
			self.statusViewController.title = @"Local preview running";
			self.statusViewController.link = localURL;
			__unsafe_unretained id weakSelf = self;
			[self.statusViewController setStopHandler:^() {
				if (weakSelf) [weakSelf preview:sender];
			}];
			
		}];
		
	}
	else {
		previewMenuItem.title = @"Preview";
		[document stopPreview];
		[self toggleStatusView];
	}
}

- (IBAction)publish:(id)sender {
	[self.publishSheetController runModalForWindow:self.window site:[self.document site]];
}

- (IBAction)showSettingsSheet:(id)sender {
	[self.settingsSheetController runModalForWindow:self.window site:[self.document site]];
}

- (void)toggleStatusView {
	NSTimeInterval animationDuration = 0.1;
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:animationDuration];
	NSView *statusView = self.statusViewController.view;
	NSRect hiddenStatusViewFrame = NSMakeRect(0.0, -statusView.frame.size.height, self.containerView.frame.size.width, statusView.frame.size.height);
	NSRect displayedStatusViewFrame = hiddenStatusViewFrame;
	displayedStatusViewFrame.origin.y = 0.0;
	if (statusView.superview) {
		[[NSAnimationContext currentContext] setCompletionHandler:^{
			[statusView removeFromSuperview];
		}];
		[[statusView animator] setFrame:hiddenStatusViewFrame];
		[[self.containerViewBottomConstraint animator] setConstant:0];
	}
	else {
		statusView.autoresizingMask = NSViewWidthSizable;
		statusView.frame = hiddenStatusViewFrame;
		[self.containerView.superview addSubview:statusView];
		[[statusView animator] setFrame:displayedStatusViewFrame];
		[[self.containerViewBottomConstraint animator] setConstant:(-1 * statusView.frame.size.height)];
	}
	[NSAnimationContext endGrouping];
}

#pragma mark - Tab View Delegate Methods

- (void)tabView:(TBTabView *)tabView didSelectIndex:(NSUInteger)index {
	self.selectedViewControllerIndex = index;
}

#pragma mark - Window Delegate Methods

- (void)windowDidLoad {
	[super windowDidLoad];
	
	self.settingsSheetController = [TBSettingsSheetController new];
	self.publishSheetController = [TBPublishSheetController new];
	self.statusViewController = [TBStatusViewController new];
	
	NSView *themeFrame = [self.window.contentView superview];
	NSRect accessoryFrame = self.accessoryView.frame;
	NSRect containerFrame = themeFrame.frame;
	accessoryFrame = NSMakeRect(containerFrame.size.width - accessoryFrame.size.width -  TBAccessoryViewInsets.right, containerFrame.size.height - accessoryFrame.size.height - TBAccessoryViewInsets.top, accessoryFrame.size.width, accessoryFrame.size.height);
	self.accessoryView.frame = accessoryFrame;
	self.accessoryView.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin;
	[[(NSButton *)self.accessoryView cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[(NSButton *)self.accessoryView cell] setShowsStateBy:NSPushInCellMask];
	[[(NSButton *)self.accessoryView cell] setHighlightsBy:NSContentsCellMask];
	[themeFrame addSubview:self.accessoryView];
	
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
