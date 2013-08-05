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
#import "TBNewSiteSheetController.h"
#import "TBSite.h"
#import "TBPost.h"
#import "TBMacros.h"
#import "TBHTTPServer.h"
#import "TBPublisher.h"
#import "TBSocketConnection.h"
#import "UKFSEventsWatcher.h"

@interface TBSiteDocument () <NSTableViewDelegate, TBSiteDelegate>
@property (nonatomic, strong) UKFSEventsWatcher *sourceWatcher;
@property (nonatomic, strong) UKFSEventsWatcher *postsWatcher;
@property (nonatomic, strong) TBNewSiteSheetController *siteSheetController;
- (void)reloadSite;
- (void)startPostsWatcher;
@end

@implementation TBSiteDocument

- (void)makeWindowControllers {
	TBSiteWindowController *windowController = [TBSiteWindowController new];
	[self windowControllerWillLoadNib:windowController];
	[self addWindowController:windowController];
	[self windowControllerDidLoadNib:windowController];
}

- (void)startPreview:(TBSiteDocumentPreviewCallback)callback {
	
	MAWeakSelfDeclare();
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSError *error;
		MAWeakSelfImport();

		[[NSProcessInfo processInfo] disableSuddenTermination];
		if (![self.site process:&error]) {
			callback(nil, error);
			return;
		}
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
		NSURL *localURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]];
		[[NSWorkspace sharedWorkspace] openURL:localURL];
		
		if (!callback){
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(localURL, error);
		});
		
		
	});
	
}

- (void)stopPreview {
	[self.sourceWatcher removeAllPaths];
	[self.server stop];
}

- (void)startPostsWatcher {
	self.postsWatcher = [UKFSEventsWatcher new];
	self.postsWatcher.delegate = self;
	self.postsWatcher.FSEventStreamCreateFlags = kFSEventStreamCreateFlagUseCFTypes;
	[self.postsWatcher addPath:self.site.postsDirectory.path];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	if (!self.fileURL) {
		self.siteSheetController = [TBNewSiteSheetController new];
		[self.siteSheetController runModalForWindow:self.windowForSheet completionHandler:^(NSString *name, NSString *author, NSURL *URL) {
			
			if (!URL) {
				// Close the window after a small delay, so that the sheet has time to close.
				[self performSelector:@selector(close) withObject:nil afterDelay:0.4];
				return;
			}
			
			NSError *error = nil;
			NSURL *defaultSite = [[NSBundle mainBundle] URLForResource:@"Default" withExtension:@"tribo"];
			if (![[NSFileManager defaultManager] copyItemAtURL:defaultSite toURL:URL error:&error])
				[NSApp presentError:error];
			if (![self readFromURL:URL ofType:@"tribo" error:&error])
				[NSApp presentError:error];
			self.fileURL = URL;
			
			[self startPostsWatcher];
			
		}];
	}
	else {
		[self startPostsWatcher];
	}
}

- (void)watcher:(id<UKFileWatcher>)watcher receivedNotification:(NSString *)notification forPath:(NSString *)path {
    [self reloadSite];
}

- (void)metadataDidChangeForSite:(TBSite *)site {
	[self reloadSite];
}

- (void)reloadSite {
	[[NSProcessInfo processInfo] disableSuddenTermination];
	if (self.server.isRunning) {
		MAWeakSelfDeclare();
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			MAWeakSelfImport();
			NSError *error;
			
			if (![self.site process:&error]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self presentError:error];
				});
				return;
			}
			
			[self.server refreshPages];
			
		});
	}
	else {
		NSError *parsingError;
		if (![self.site parsePosts:&parsingError])
			[self presentError:parsingError];
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
