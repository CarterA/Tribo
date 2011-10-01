//
//  TBSite.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSite.h"
#import "TBPost.h"
#import "GRMustache.h"

@interface TBSite ()
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSArray *recentPosts;
@property (nonatomic, strong) GRMustacheTemplate *postTemplate;
- (void)parsePosts;
- (void)writePosts;
@end

@implementation TBSite
@synthesize root=_root;
@synthesize destination=_destination;
@synthesize sourceDirectory=_sourceDirectory;
@synthesize postsDirectory=_postsDirectory;
@synthesize templatesDirectory=_templatesDirectory;
@synthesize posts=_posts;
@synthesize recentPosts=_recentPosts;
@synthesize postTemplate=_postTemplate;
- (void)process {
	
	// Find and compile the post template.
	NSURL *defaultTemplateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Default.mustache" isDirectory:NO];
	NSString *rawDefaultTemplate = [NSString stringWithContentsOfURL:defaultTemplateURL encoding:NSUTF8StringEncoding error:nil];
	NSURL *postPartialURL = [self.templatesDirectory URLByAppendingPathComponent:@"Post.mustache" isDirectory:NO];
	NSString *rawPostPartial = [NSString stringWithContentsOfURL:postPartialURL encoding:NSUTF8StringEncoding error:nil];
	NSString *rawPostTemplate = [rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:rawPostPartial];
	self.postTemplate = [GRMustacheTemplate parseString:rawPostTemplate error:nil];
	
	// Take care of posts early so that pages can use them.
	[self parsePosts];
	[self writePosts];
	
	// Recurse through the entire "Source" directory for pages and files.
	BOOL sourceDirectoryIsDirectory = NO;
	BOOL sourceDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.sourceDirectory.path isDirectory:&sourceDirectoryIsDirectory];
	if (!sourceDirectoryIsDirectory || !sourceDirectoryExists) return;
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.sourceDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
		return YES;
	}];
	for (NSURL *URL in enumerator) {
		
		BOOL URLIsDirectory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&URLIsDirectory];
		if (URLIsDirectory) continue;
		
		NSString *extension = [URL pathExtension];
		NSString *relativePath = [URL.path stringByReplacingOccurrencesOfString:self.sourceDirectory.path withString:@""];
		NSURL *destinationURL = [[self.destination URLByAppendingPathComponent:relativePath] URLByStandardizingPath];
		NSURL *destinationDirectory = [destinationURL URLByDeletingLastPathComponent];
		[[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		if ([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path])
			[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
		
		if ([extension isEqualToString:@"mustache"]) {
			TBPage *page = [TBPage pageWithURL:URL inSite:self];
			NSString *rawPageTemplate = [rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:page.content];
			GRMustacheTemplate *pageTemplate = [GRMustacheTemplate parseString:rawPageTemplate error:nil];
			NSString *renderedPage = [pageTemplate renderObject:page];
			[renderedPage writeToURL:[[destinationURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
		else {
			[[NSFileManager defaultManager] copyItemAtURL:URL toURL:destinationURL error:nil];
		}
	}
	
}
- (void)parsePosts {
	BOOL postsDirectoryIsDirectory = NO;
	BOOL postsDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.postsDirectory.path isDirectory:&postsDirectoryIsDirectory];
	if (!postsDirectoryIsDirectory || !postsDirectoryExists) return;
	if (!self.posts) self.posts = [NSMutableArray array];
	for (NSURL *postURL in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.postsDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
		TBPost *post = [TBPost postWithURL:postURL];
		[self.posts addObject:post];
	}
	self.posts = [NSMutableArray arrayWithArray:[[self.posts reverseObjectEnumerator] allObjects]];
	self.recentPosts = [self.posts subarrayWithRange:NSMakeRange(0, 5)];
}
- (void)writePosts {
	
	for (TBPost *post in self.posts) {
		
		post.stylesheets = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"post" forKey:@"stylesheetName"]];
		
		// Create the path to the folder where we are going to write the post file.
		// The directory structure we create is /YYYY/MM/DD/slug/
		NSDateFormatter *formatter = [NSDateFormatter new];
		formatter.dateFormat = @"yyyy/MM/dd";
		NSString *directoryStructure = [formatter stringFromDate:post.date];
		NSURL *destinationDirectory = [[self.destination URLByAppendingPathComponent:directoryStructure isDirectory:YES] URLByAppendingPathComponent:post.slug isDirectory:YES];
		[[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		
		// Set up the template loader with this post's content, and then render it all into the post template.
		NSString *renderedContent = [self.postTemplate renderObject:post];
		
		// Write the post to the destination directory.
		NSURL *destinationURL = [destinationDirectory URLByAppendingPathComponent:@"index.html" isDirectory:NO];
		[renderedContent writeToURL:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
	}
	
}
@end