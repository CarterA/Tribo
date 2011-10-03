//
//  TBSiteDocument.m
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSiteDocument.h"
#import "TBSite.h"
#import "TBPost.h"
#import "HTTPServer.h"
#import "Safari.h"
#import "UKFSEventsWatcher.h"

@interface TBSiteDocument ()
@property (nonatomic, strong) UKFSEventsWatcher *eventsWatcher;
@property (nonatomic, strong) HTTPServer *server;
- (void)refreshLocalhostPages;
@end

@implementation TBSiteDocument
@synthesize site=_site;
@synthesize postTableView=_postTableView;
@synthesize progressIndicator=_progressIndicator;
@synthesize eventsWatcher=_eventsWatcher;
@synthesize server=_server;

- (NSString *)windowNibName { return @"TBSiteDocument"; }

- (IBAction)preview:(id)sender {
	NSButton *button = sender;
	if (!self.server.isRunning) {
		
		button.hidden = YES;
		self.progressIndicator.hidden = NO;
		[self.progressIndicator startAnimation:self];
		[self.site process];
		
		if (!self.eventsWatcher) {
			self.eventsWatcher = [UKFSEventsWatcher new];
			self.eventsWatcher.delegate = self;
		}
		[self.eventsWatcher addPath:self.site.sourceDirectory.path];
		[self.eventsWatcher addPath:self.site.postsDirectory.path];
		[self.eventsWatcher addPath:self.site.templatesDirectory.path];
		
		// Start up the HTTP server so that the site can be previewed.
		if (!self.server) {
			self.server = [HTTPServer new];
			self.server.documentRoot = self.site.destination.path;
		}
		[self.server start:nil];
		[self refreshLocalhostPages];
		
		[self.progressIndicator stopAnimation:self];
		self.progressIndicator.hidden = YES;
		button.title = @"Stop Server";
		[button sizeToFit];
		button.hidden = NO;
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]]];
		
	}
	else {
		[self.eventsWatcher removeAllPaths];
		[self.server stop];
		button.title = @"Preview";
	}
}

- (void)refreshLocalhostPages {
	// Refresh any Safari tabs open to http://localhost:port/**.
	SafariApplication *safari = (SafariApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.Safari"];
	for (SafariWindow *window in safari.windows) {
		for (SafariTab *tab in window.tabs) {
			if ([tab.URL hasPrefix:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]]) {
				tab.URL = tab.URL;
			}
		}
	}
}
- (void)watcher:(id<UKFileWatcher>)kQueue receivedNotification:(NSString *)notification forPath:(NSString *)path {
	[self.site process];
	[self refreshLocalhostPages];
}

- (void)postWasDoubleClicked:(id)sender {
	TBPost *clickedPost = [self.site.posts objectAtIndex:[self.postTableView clickedRow]];
	[[NSWorkspace sharedWorkspace] openURL:clickedPost.URL];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
    [super windowControllerDidLoadNib:controller];
	self.postTableView.target = self;
	self.postTableView.doubleAction = @selector(postWasDoubleClicked:);
}

- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	self.site = [TBSite siteWithRoot:URL];
	[self.site parsePosts];
	return YES;
}

@end