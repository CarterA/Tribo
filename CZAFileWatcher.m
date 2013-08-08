//
//  CZAFileWatcher.m
//
//  Created by Carter Allen on 8/7/13.
//  Copyright (c) 2013 Carter Allen.
//
//  Released under the MIT License.
//  See the included License.md file for details.
//

#import "CZAFileWatcher.h"

@interface CZAFileWatcher () {
	BOOL _eventStreamIsRunning;
}
@property (readonly) TBFileWatcherChangesHandler changesHandler;
@property (nonatomic, assign) FSEventStreamRef eventStream;
static void eventCallback(ConstFSEventStreamRef eventStreamRef, void *callbackInfo, size_t numberOfEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);
@end

@implementation CZAFileWatcher

#pragma mark - Initialization and Deallocation

+ (instancetype)fileWatcherForURLs:(NSArray *)URLs changesHandler:(TBFileWatcherChangesHandler)changesHandler {
	return [[[self class] alloc] initForURLs:URLs changesHandler:changesHandler];
}

- (id)initForURLs:(NSArray *)URLs changesHandler:(TBFileWatcherChangesHandler)changesHandler {
	self = [super init];
	if (self) {
		_URLs = [URLs copy];
		_changesHandler = [changesHandler copy];
		[self cza_createEventStream];
		if (!_eventStream) return nil;
	}
	return self;
}

- (void)dealloc {
	if (_eventStreamIsRunning)
		FSEventStreamStop(_eventStream);
	FSEventStreamInvalidate(_eventStream);
	FSEventStreamRelease(_eventStream);
}

#pragma mark - Event Stream Interaction

- (void)startWatching {
	if (!_eventStreamIsRunning)
		FSEventStreamStart(self.eventStream);
	_eventStreamIsRunning = YES;
}

- (void)stopWatching {
	if (_eventStreamIsRunning)
		FSEventStreamStop(self.eventStream);
	_eventStreamIsRunning = NO;
}

- (void)cza_createEventStream {
	FSEventStreamContext context = {
		.version = 0,
		.info = (__bridge void *)self,
		.retain = NULL,
		.release = NULL,
		.copyDescription = NULL
	};
	CFArrayRef paths = (__bridge CFArrayRef)[[self cza_directoryURLs] valueForKey:@"path"];
	FSEventStreamRef eventStream = FSEventStreamCreate(kCFAllocatorDefault, &eventCallback, &context, paths, kFSEventStreamEventIdSinceNow, 1.0, kFSEventStreamCreateFlagUseCFTypes);
	FSEventStreamSetDispatchQueue(eventStream, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
	self.eventStream = eventStream;
}

#pragma mark - URL Processing

- (NSArray *)cza_directoryURLs {
	NSArray *URLs = self.URLs;
	NSMutableArray *directoryURLs = [NSMutableArray arrayWithCapacity:[URLs count]];
	for (NSURL *URL in self.URLs) {
		BOOL isDirectory = NO;
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&isDirectory];
		if (isDirectory && exists)
			[directoryURLs addObject:URL];
		else if (!isDirectory && exists)
			[directoryURLs addObject:[URL URLByDeletingLastPathComponent]];
	}
	return directoryURLs;
}

#pragma mark - FSEvents Callback Function

static void eventCallback(ConstFSEventStreamRef eventStreamRef, void *callbackInfo, size_t numberOfEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
	CZAFileWatcher *fileWatcher = (__bridge CZAFileWatcher *)callbackInfo;
	NSArray *paths = (__bridge NSArray *)eventPaths;
	NSMutableArray *URLs = [NSMutableArray arrayWithCapacity:(NSUInteger)numberOfEvents];
	for (NSString *path in paths) {
		NSURL *URL = [NSURL fileURLWithPath:path];
		[URLs addObject:URL];
	}
	if (fileWatcher.changesHandler)
		fileWatcher.changesHandler(URLs);
}

@end
