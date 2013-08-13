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
#import "NSResponder+TBAdditions.h"
#import "CZAFileWatcher.h"

@interface TBSiteDocument () <NSTableViewDelegate, TBSiteDelegate>
@property (nonatomic, strong) CZAFileWatcher *sourceWatcher;
@property (nonatomic, strong) CZAFileWatcher *postsWatcher;
@property (nonatomic, strong) TBNewSiteSheetController *siteSheetController;
- (void)reloadSite;
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
		
		if (!self.server) {
			self.server = [TBHTTPServer new];
			self.server.connectionClass = [TBSocketConnection class];
			self.server.documentRoot = self.site.destination.path;
		}
		[self.server start:nil];
		[self.server refreshPages];
		[self.sourceWatcher startWatching];
		[self.postsWatcher stopWatching];
		NSURL *localURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d", self.server.listeningPort]];
		[[NSWorkspace sharedWorkspace] openURL:localURL];
		
		self->_previewIsRunning = YES;
		
		if (!callback){
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(localURL, error);
		});
		
		
	});
	
}

- (void)stopPreview {
	[self.sourceWatcher stopWatching];
	[self.postsWatcher startWatching];
	[self.server stop];
	_previewIsRunning = NO;
}

- (CZAFileWatcher *)sourceWatcher {
	if (_sourceWatcher) return _sourceWatcher;
	MAWeakSelfDeclare();
	_sourceWatcher = [CZAFileWatcher fileWatcherForURLs:@[self.site.sourceDirectory, self.site.postsDirectory, self.site.templatesDirectory] changesHandler:^(NSArray *changedURLs) {
		MAWeakSelfImport();
		[self reloadSite];
	}];
	return _sourceWatcher;
}

- (CZAFileWatcher *)postsWatcher {
	if (_postsWatcher) return _postsWatcher;
	MAWeakSelfDeclare();
	_postsWatcher = [CZAFileWatcher fileWatcherForURLs:@[self.site.postsDirectory] changesHandler:^(NSArray *changedURLs) {
		MAWeakSelfImport();
		[self reloadSite];
	}];
	return _postsWatcher;
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
				[NSApp tb_presentErrorOnMainQueue:error];
			if (![self readFromURL:URL ofType:@"tribo" error:&error])
				[NSApp tb_presentErrorOnMainQueue:error];
			self.fileURL = URL;
			
			[self.postsWatcher startWatching];
			
		}];
	}
	else {
		[self.postsWatcher startWatching];
	}
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
				[NSApp tb_presentErrorOnMainQueue:error];
				return;
			}
			
			[self.server refreshPages];
			
		});
	}
	else {
		NSError *parsingError;
		if (![self.site parsePosts:&parsingError])
			[NSApp tb_presentErrorOnMainQueue:parsingError];
	}
    [[NSProcessInfo processInfo] enableSuddenTermination];
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName { return YES; }

- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	self.site = [TBSite siteWithRoot:URL];
	self.site.delegate = self;
    
    BOOL success = [self.site parsePosts:outError];
    if (!success) {
        [NSApp tb_presentErrorOnMainQueue:*outError];
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
