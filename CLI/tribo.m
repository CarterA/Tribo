//
//  Tribo.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSite.h"
#import "HTTPServer.h"
#import <ApplicationServices/ApplicationServices.h>

void printHeader(const char *header);

int main (int argumentCount, const char *arguments[]) {
	@autoreleasepool {
		NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
		printHeader("Compiling website...");
		TBSite *site = [TBSite new];
		site.root = [NSURL fileURLWithPath:[NSFileManager defaultManager].currentDirectoryPath];
		site.destination = [site.root URLByAppendingPathComponent:@"Output" isDirectory:YES];
		site.sourceDirectory = [site.root URLByAppendingPathComponent:@"Source" isDirectory:YES];
		site.postsDirectory = [site.root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
		site.templatesDirectory = [site.root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
		[site process];
		HTTPServer *server = [HTTPServer new];
		server.documentRoot = site.destination.path;
		server.port = 4000;
		[server start:nil];
		printHeader("Development server started at http://localhost:4000/");
		printHeader("Opening website in default web browser...");
		LSOpenCFURLRef((__bridge CFURLRef)[NSURL URLWithString:@"http://localhost:4000/"], NULL);
		[runLoop run];
	}
    return 0;
}

void printHeader(const char *header) {
	printf("\e[1m\e[34m==>\e[0m\e[0m ");
	printf("\e[1m%s\e[0m\n", header);
}