//
//  TBSiteDocument.m
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSiteDocument.h"
#import "TBSiteWindowController.h"
#import "TBAddPostSheetController.h"
#import "TBSite.h"
#import "TBPost.h"
#import "TBHTTPServer.h"
#import "TBPublisher.h"
#import "TBSocketConnection.h"
#import "UKFSEventsWatcher.h"
#import <Quartz/Quartz.h>

@interface TBSiteDocument () <NSTableViewDelegate, TBSiteDelegate>
@property (nonatomic, strong) UKFSEventsWatcher *sourceWatcher;
@property (nonatomic, strong) UKFSEventsWatcher *postsWatcher;
- (void)reloadSite;
@end

@implementation TBSiteDocument
@synthesize site=_site;
@synthesize sourceWatcher=_sourceWatcher;
@synthesize postsWatcher=_postsWatcher;
@synthesize server=_server;

- (void)makeWindowControllers {
	TBSiteWindowController *windowController = [TBSiteWindowController new];
	[self windowControllerWillLoadNib:windowController];
	[self addWindowController:windowController];
	[self windowControllerDidLoadNib:windowController];
}

- (void)startPreview:(TBSiteDocumentPreviewCallback)callback {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[NSProcessInfo processInfo] disableSuddenTermination];
		NSError *error = nil;
		[self.site process:&error];
		[[NSProcessInfo processInfo] enableSuddenTermination];
        
		if (!self.sourceWatcher) {
			self.sourceWatcher = [UKFSEventsWatcher new];
			self.sourceWatcher.delegate = self;
			self.sourceWatcher.FSEventStreamCreateFlags = kFSEventStreamCreateFlagUseCFTypes;
		}
		[self.sourceWatcher addPath:self.site.sourceDirectory.path];
		[self.sourceWatcher addPath:self.site.postsDirectory.path];
		[self.sourceWatcher addPath:self.site.templatesDirectory.path];
		if (!self.server) {
			self.server = [TBHTTPServer new];
			self.server.connectionClass = [TBSocketConnection class];
			self.server.documentRoot = self.site.destination.path;
		}
		[self.server start:nil];
		[self.server refreshPages];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]]];
		
		if (!callback){
            return;
        }
		
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(error);
		});
		
	});
	
}

- (void)stopPreview {
	[self.sourceWatcher removeAllPaths];
	[self.server stop];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	self.postsWatcher = [UKFSEventsWatcher new];
	self.postsWatcher.delegate = self;
	self.postsWatcher.FSEventStreamCreateFlags = kFSEventStreamCreateFlagUseCFTypes;
	[self.postsWatcher addPath:self.site.postsDirectory.path];
}

- (void)watcher:(id<UKFileWatcher>)watcher receivedNotification:(NSString *)notification forPath:(NSString *)path {
    [self reloadSite];
}

- (void)metadataDidChangeForSite:(TBSite *)site {
	[self reloadSite];
	
}

- (void)reloadSite {
	[[NSProcessInfo processInfo] disableSuddenTermination];
    NSError *error = nil;
    BOOL success = YES;
	if (self.server.isRunning) {
        success = [self.site process:&error];
        if (success) {
            [self.server refreshPages];
        }
	}
	else {
		success = [self.site parsePosts:&error];
	}
    if (!success) {
        [self presentError:error];
    }
    [[NSProcessInfo processInfo] enableSuddenTermination];
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName { return YES; }

- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	self.site = [TBSite siteWithRoot:URL];
	self.site.delegate = self;
    
    BOOL success = [self.site parsePosts:outError];
    if (!success) {
        [NSApp presentError:*outError];
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
        return NO;
    }
	return YES;
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
	// Do nothing. We don't save things.
}

- (void)updateChangeCountWithToken:(id)changeCountToken forSaveOperation:(NSSaveOperationType)saveOperation {
	// Again, do nothing. See -updateChangeCount:.
}

@end
