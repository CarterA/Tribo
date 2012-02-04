//
//  TBSiteDocument.m
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSiteDocument.h"
#import "TBSiteWindowController.h"
#import "TBAddPostSheetController.h"
#import "TBSite.h"
#import "TBPost.h"
#import "HTTPServer.h"
#import "Safari.h"
#import "UKFSEventsWatcher.h"
#import <Quartz/Quartz.h>

@interface TBSiteDocument () <NSTableViewDelegate>
@property (nonatomic, strong) UKFSEventsWatcher *sourceWatcher;
@property (nonatomic, strong) UKFSEventsWatcher *postsWatcher;
- (void)refreshLocalhostPages;
@end

@implementation TBSiteDocument
@synthesize site=_site;
@synthesize sourceWatcher=_sourceWatcher;
@synthesize postsWatcher=_postsWatcher;
@synthesize server=_server;

- (void)makeWindowControllers {
	TBSiteWindowController *windowController = [TBSiteWindowController new];
	[self addWindowController:windowController];
}

- (void)startPreview:(TBSiteDocumentPreviewCallback)callback {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSError *error = nil;
		[self.site process:&error];
		
		if (!self.sourceWatcher) {
			self.sourceWatcher = [UKFSEventsWatcher new];
			self.sourceWatcher.delegate = self;
		}
		[self.sourceWatcher addPath:self.site.sourceDirectory.path];
		[self.sourceWatcher addPath:self.site.postsDirectory.path];
		[self.sourceWatcher addPath:self.site.templatesDirectory.path];
		if (!self.server) {
			self.server = [HTTPServer new];
			self.server.documentRoot = self.site.destination.path;
		}
		[self.server start:nil];
		[self refreshLocalhostPages];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]]];
		
		if (!callback) return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(error);
		});
		
	});
	
}

- (void)stopPreview {
	[self.sourceWatcher removeAllPaths];
	[self.server stop];
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

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	self.postsWatcher = [UKFSEventsWatcher new];
	self.postsWatcher.delegate = self;
	[self.postsWatcher addPath:self.site.postsDirectory.path];
}

- (void)watcher:(id<UKFileWatcher>)watcher receivedNotification:(NSString *)notification forPath:(NSString *)path {
    NSError *error = nil;
    BOOL success = YES;
	if (watcher == self.sourceWatcher || self.server.isRunning) {
        success = [self.site process:&error];
        if (success) {
            [self refreshLocalhostPages];
        }
	}
	else if (watcher == self.postsWatcher) {
		success = [self.site parsePosts:&error];
	}
    if (!success) {
        [self presentError:error];
    }
}

- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	self.site = [TBSite siteWithRoot:URL];
    
    BOOL success = [self.site parsePosts:outError];
    if (!success) {
        [NSApp presentError:*outError];
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
        return NO;
    }
	return YES;
}

@end