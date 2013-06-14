//
//  TBPostsViewController.m
//  Tribo
//
//  Created by Carter Allen on 10/24/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPostsViewController.h"
#import "TBAddPostSheetController.h"
#import "TBSiteDocument.h"
#import "TBSite.h"
#import "TBPost.h"
#import "TBTableView.h"
#import "TBHTTPServer.h"

@interface TBPostsViewController () <TBTableViewDelegate>
- (void)moveURLsToTrash:(NSArray *)URLs;
- (void)undoMoveToTrashForURLs:(NSDictionary *)URLs;
@end

@implementation TBPostsViewController
@synthesize document=_document;
@synthesize postTableView=_postTableView;

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
}

#pragma mark - Actions

- (IBAction)editPost:(id)sender {
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	TBPost *clickedPost = (document.site.posts)[[self.postTableView clickedRow]];
	[[NSWorkspace sharedWorkspace] openURL:clickedPost.URL];
}

- (IBAction)previewPost:(id)sender {
	TBPost *clickedPost = (self.document.site.posts)[[self.postTableView clickedRow]];
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = @"yyyy/MM/dd";
	NSString *postURLPrefix = [[formatter stringFromDate:clickedPost.date] stringByAppendingPathComponent:clickedPost.slug];
	NSURL *postPreviewURL = [NSURL URLWithString:postURLPrefix relativeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.document.server.listeningPort]]];
	[[NSWorkspace sharedWorkspace] openURL:postPreviewURL];
	
}

- (IBAction)revealPost:(id)sender {
	TBPost *clickedPost = (self.document.site.posts)[[self.postTableView clickedRow]];
	[[NSWorkspace sharedWorkspace] selectFile:clickedPost.URL.path inFileViewerRootedAtPath:nil];
}

- (void)tableView:(NSTableView *)tableView shouldDeleteRows:(NSIndexSet *)rowIndexes {
	NSArray *selectedPosts = [self.document.site.posts objectsAtIndexes:rowIndexes];
	NSArray *postURLs = [selectedPosts valueForKey:@"URL"];
	[self moveURLsToTrash:postURLs];
}

- (void)moveURLsToTrash:(NSArray *)URLs {
	[[NSWorkspace sharedWorkspace] recycleURLs:URLs completionHandler:^(NSDictionary *newURLs, NSError *error) {
		
		if (error) [self presentError:error];
		
		[self.document.undoManager registerUndoWithTarget:self selector:@selector(undoMoveToTrashForURLs:) object:newURLs];
		[self.document.undoManager setActionName:@"Move to Trash"];
		
		NSError *postParsingError = nil;
		BOOL success = [self.document.site parsePosts:&postParsingError];
		if (!success) [self presentError:postParsingError];
		
	}];
}

- (void)undoMoveToTrashForURLs:(NSDictionary *)URLs {
	[URLs enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		NSURL *originalURL = key;
		NSURL *trashURL = object;
		NSError *error = nil;
		BOOL success = [[NSFileManager defaultManager] moveItemAtURL:trashURL toURL:originalURL error:&error];
		if (!success) [self presentError:error];
		NSError *postParsingError = nil;
		success = [self.document.site parsePosts:&postParsingError];
		if (!success) [self presentError:postParsingError];
	}];
	[self.document.undoManager registerUndoWithTarget:self selector:@selector(moveURLsToTrash:) object:URLs.allKeys];
	[self.document.undoManager setActionName:@"Move to Trash"];
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
		if ([((TBPost *)(self.document.site.posts)[index]).URL isEqual:item]) continue;
	}
	return [self.postTableView rectOfRow:index];
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
	TBPost *requestedPost = (self.document.site.posts)[index];
	return requestedPost.URL;
}

@end
