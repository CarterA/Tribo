//
//  CZAFileWatcher.h
//
//  Created by Carter Allen on 8/7/13.
//  Copyright (c) 2013 Carter Allen.
//
//  Released under the MIT License.
//  See the included License.md file for details.
//

#import <Foundation/Foundation.h>

/*!
 @class CZAFileWatcher
 @discussion A file watcher monitors an array of filesystem URLs for changes, 
 and executes a block whenever changes occur. File watcher objects are 
 immutable, therefore the URLs and handler block provided during initialization 
 cannot be changed. CZAFileWatcher is implemented using OS X's FSEvents 
 facility, and requires a Grand Central Dispatch queue to function properly. 
 A run loop, however, is not necessary.
 */

@interface CZAFileWatcher : NSObject

typedef void(^TBFileWatcherChangesHandler)(NSArray *changedURLs);

/*!
 Create a file watcher, configured to watch an array of filesystem URLs and call
 a handler block when changes are detected.
 @param URLs
	An array of filesystem URLs to watch for changes.
 @param changesHandler
	A block to execute whenever changes to the specified URLs occur. The handler 
	will be passed an array of the URLs that were affected by the change.
 */
+ (instancetype)fileWatcherForURLs:(NSArray *)URLs
					changesHandler:(TBFileWatcherChangesHandler)changesHandler;

/*!
 Starts watching the URLs for changes. If the watcher is already running, this 
 method does nothing.
 */
- (void)startWatching;

/*!
 Stops watching the URLs for changes. If the watcher is already stopped, this 
 method does nothing.
 */
- (void)stopWatching;

/*!
 The filesystem URLs watched by the file watcher.
 */
@property (readonly) NSArray *URLs;

@end
