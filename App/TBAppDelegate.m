//
//  TBAppDelegate.m
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBAppDelegate.h"
#import "TBSite.h"
#import "HTTPServer.h"
#import "UKFSEventsWatcher.h"

@interface TBAppDelegate ()
@property (nonatomic, strong) UKFSEventsWatcher *queue;
@end

@implementation TBAppDelegate
@synthesize window=_window;
@synthesize site=_site;
@synthesize server=_server;
@synthesize queue=_queue;
- (void)awakeFromNib {
	
	// Configure and process the site for the first time.
	self.site = [TBSite new];
	self.site.root = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"root"] isDirectory:YES];
	self.site.destination = [self.site.root URLByAppendingPathComponent:@"Output" isDirectory:YES];
	self.site.sourceDirectory = [self.site.root URLByAppendingPathComponent:@"Source" isDirectory:YES];
	self.site.postsDirectory = [self.site.root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
	self.site.templatesDirectory = [self.site.root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
	[self.site process];
	
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	// Set up UKFSEventsWatcher to notify us when the root path is modified so we can recompile.
	self.queue = [UKFSEventsWatcher new];
	self.queue.delegate = self;
	[self.queue addPath:self.site.sourceDirectory.path];
	[self.queue addPath:self.site.postsDirectory.path];
	[self.queue addPath:self.site.templatesDirectory.path];
	
	// Start up the HTTP server so that the site can be previewed.
	self.server = [HTTPServer new];
	self.server.documentRoot = self.site.destination.path;
	self.server.port = 4000;
	[self.server start:nil];
	
}
- (void)watcher:(id<UKFileWatcher>)kQueue receivedNotification:(NSString *)notification forPath:(NSString *)path {
	[self.site process];
}
@end