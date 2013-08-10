//
//  watch-file.m
//  CZAFileWatcher
//
//  Created by Carter Allen on 8/7/13.
//  Copyright (c) 2013 Carter Allen.
//
//  Released under the MIT License.
//  See the included License.md file for details.
//

#import <Foundation/Foundation.h>
#import "CZAFileWatcher.h"

int main(int argc, const char * argv[]) {
	
	@autoreleasepool {
		
		if (argc < 2) {
			printf("watch-file requires one or more file paths as arguments.\n");
			return EXIT_FAILURE;
		}
		
		NSMutableArray *URLs = [NSMutableArray arrayWithCapacity:argc - 1];
		for (NSUInteger index = 1; index < argc; index++) {
			NSString *path = [NSString stringWithUTF8String:argv[index]];
			[URLs addObject:[NSURL fileURLWithPath:[path stringByStandardizingPath]]];
		}
		
		CZAFileWatcher *watcher = [CZAFileWatcher fileWatcherForURLs:URLs changesHandler:^(NSArray *changedURLs) {
			for (NSURL *URL in changedURLs) {
				printf("Change detected at path: %s\n", [URL.path UTF8String]);
			}
		}];
		[watcher startWatching];
		
		dispatch_main();
		
	}
	
	return EXIT_SUCCESS;
}

