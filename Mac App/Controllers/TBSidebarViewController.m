//
//  TBSidebarViewController.m
//  Tribo
//
//  Created by Carter Allen on 8/1/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSidebarViewController.h"
#import "TBPostsViewController.h"
#import "TBTemplatesViewController.h"
#import "TBSourceViewController.h"
#import "TBTabView.h"
#import "TBPost.h"

@interface TBSidebarViewController () <TBTabViewDelegate, TBPostsViewControllerDelegate>
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) TBViewController *selectedViewController;
@property (nonatomic, weak) IBOutlet TBTabView *tabView;
@property (nonatomic, weak) IBOutlet NSView *contentView;
@end

@implementation TBSidebarViewController

- (id)init {
	self = [super init];
	if (self) {
		self.viewControllers = @[
			[TBPostsViewController new],
			[TBTemplatesViewController new],
			[TBSourceViewController new]
		];
		self.selectedViewController = self.viewControllers[0];
		for (TBViewController *viewController in self.viewControllers) {
			if ([viewController respondsToSelector:@selector(setDelegate:)])
				[viewController setValue:self forKey:@"delegate"];
		}
	}
	return self;
}

- (NSString *)defaultNibName {
	return @"TBSidebarView";
}

- (void)viewDidLoad {
	[self configureTabView];
	[self updateContentView];
}

- (void)setDocument:(TBSiteDocument *)document {
	[super setDocument:document];
	[self.viewControllers setValue:document forKey:@"document"];
}

- (void)setSelectedViewController:(TBViewController *)selectedViewController {
	_selectedViewController = selectedViewController;
	[self updateContentView];
}

- (void)setSelectedFile:(NSURL *)selectedFile {
	_selectedFile = selectedFile;
	if (self.delegate) [self.delegate sidebarViewDidSelectFile:selectedFile];
}

- (void)configureTabView {
	self.tabView.titles = [self.viewControllers valueForKey:@"title"];
}

- (void)tabView:(TBTabView *)tabView didSelectIndex:(NSUInteger)index {
	self.selectedViewController = self.viewControllers[index];
}

- (void)postsViewDidSelectPost:(TBPost *)post {
	self.selectedFile = post.URL;
}

- (void)updateContentView {
	if (!self.isViewLoaded) return;
	NSView *newView = self.selectedViewController.view;
	newView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
	NSView *oldView = self.contentView;
	if (newView == oldView) return;
	newView.frame = oldView.frame;
	[self.view replaceSubview:self.contentView with:newView];
	self.contentView = newView;
}

@end
