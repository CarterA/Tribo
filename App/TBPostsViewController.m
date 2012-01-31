//
//  TBPostsViewController.m
//  Tribo
//
//  Created by Carter Allen on 10/24/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPostsViewController.h"
#import "TBAddPostSheetController.h"
#import "TBSiteDocument.h"
#import "TBSite.h"
#import "TBPost.h"
#import "HTTPServer.h"

@implementation TBPostsViewController
@synthesize document=_document;
@synthesize postTableView=_postTableView;
@synthesize progressIndicator=_progressIndicator;
@synthesize previewButton=_previewButton;
@synthesize postCountLabel=_postCountLabel;
@synthesize addPostSheetController=_addPostSheetController;

#pragma mark - View Controller Configuration

- (NSString *)defaultNibName {
	return @"TBPostsView";
}

- (NSString *)title {
	return @"Posts";
}

- (void)viewDidLoad {
	self.postTableView.target = self;
	self.postTableView.doubleAction = @selector(editPost:);
	((NSCell *)self.postCountLabel.cell).backgroundStyle = NSBackgroundStyleRaised;
	self.addPostSheetController = [TBAddPostSheetController new];
	[self.postCountLabel.cell setBackgroundStyle:NSBackgroundStyleRaised];
	[self.postCountLabel.cell setTextColor:[NSColor controlTextColor]];
}

#pragma mark - Actions

- (IBAction)preview:(id)sender {
	
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	if (!document.server.isRunning) {
		
		self.previewButton.hidden = YES;
		self.progressIndicator.hidden = NO;
		[self.progressIndicator startAnimation:self];
		
		[document startPreview];
		
		[self.progressIndicator stopAnimation:self];
		self.progressIndicator.hidden = YES;
		self.previewButton.title = @"Stop Server";
		[self.previewButton sizeToFit];
		self.previewButton.hidden = NO;
		
	}
	else {
		[document stopPreview];
		self.previewButton.title = @"Preview";
	}
}

- (IBAction)editPost:(id)sender {
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	TBPost *clickedPost = [document.site.posts objectAtIndex:[self.postTableView clickedRow]];
	[[NSWorkspace sharedWorkspace] openURL:clickedPost.URL];
}

- (IBAction)previewPost:(id)sender {
	if (!self.document.server.isRunning) [self preview:nil];
	TBPost *clickedPost = [self.document.site.posts objectAtIndex:[self.postTableView clickedRow]];
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = @"yyyy/MM/dd";
	NSString *postURLPrefix = [[formatter stringFromDate:clickedPost.date] stringByAppendingPathComponent:clickedPost.slug];
	NSURL *postPreviewURL = [NSURL URLWithString:postURLPrefix relativeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.document.server.listeningPort]]];
	[[NSWorkspace sharedWorkspace] openURL:postPreviewURL];
	
}

- (IBAction)revealPost:(id)sender {
	TBPost *clickedPost = [self.document.site.posts objectAtIndex:[self.postTableView clickedRow]];
	[[NSWorkspace sharedWorkspace] selectFile:clickedPost.URL.path inFileViewerRootedAtPath:nil];
}

- (IBAction)showAddPostSheet:(id)sender {
	[self.addPostSheetController runModalForWindow:self.document.windowForSheet completionBlock:^(NSString *title, NSString *slug) {
        NSError *error = nil;
        NSURL *siteURL = [self.document.site addPostWithTitle:title slug:slug error:&error];
        if (!siteURL) {
            [self presentError:error];
        }
	}];
}

#pragma mark - QuickLook Support

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
	return self.document.site.posts.count;
}

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
	return NO;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item {
	NSUInteger index = 0;
	for (index = 0; index < self.document.site.posts.count; index++) {
		if ([((TBPost *)[self.document.site.posts objectAtIndex:index]).URL isEqual:item]) continue;
	}
	return [self.postTableView rectOfRow:index];
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
	TBPost *requestedPost = [self.document.site.posts objectAtIndex:index];
	return requestedPost.URL;
}

@end