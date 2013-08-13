//
//  Tribo.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSite.h"
#import "TBHTTPServer.h"
#import "TBSocketConnection.h"
#import "CZAFileWatcher.h"
#import <ApplicationServices/ApplicationServices.h>

void printHeader(const char *header);
void printError(const char *errorMessage);

int main (int argumentCount, const char *arguments[]) {
	
	@autoreleasepool {
		
		printHeader("Compiling website...");
		TBSite *site = [TBSite siteWithRoot:[NSURL fileURLWithPath:[NSFileManager defaultManager].currentDirectoryPath]];
        
        NSError *error = nil;
        if (![site process:&error]) {
            printError([[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            exit((int)[error code]);
        }
        
		TBHTTPServer *server = [TBHTTPServer new];
		server.documentRoot = site.destination.path;
		server.port = 4000;
		[server start:nil];
		printHeader("Development server started at http://localhost:4000/");
		printHeader("Opening website in default web browser...");
		LSOpenCFURLRef((__bridge CFURLRef)[NSURL URLWithString:@"http://localhost:4000/"], NULL);
		
		CZAFileWatcher *watcher = [CZAFileWatcher fileWatcherForURLs:@[site.sourceDirectory, site.postsDirectory, site.templatesDirectory] changesHandler:^(NSArray *changedURLs) {
			[site process:nil];
			[server refreshPages];
		}];
		[watcher startWatching];
		
		dispatch_main();
		
	}
	
    return EXIT_SUCCESS;
	
}

void printHeader(const char *header) {
	printf("\e[1m\e[34m==>\e[0m\e[0m ");
	printf("\e[1m%s\e[0m\n", header);
}

void printError(const char *errorMessage) {
    fprintf(stderr, "\e[1m\e[34m==>\e[0m\e[0m ");
	fprintf(stderr, "\e[1m%s\e[0m\n", errorMessage);
}
