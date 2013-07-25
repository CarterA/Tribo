//
//  TBSite.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSite.h"
#import "TBPost.h"
#import "TBError.h"
#import "GRMustache.h"
#import "TBAsset.h"
#import "NSDateFormatter+TBAdditions.h"

@interface TBSite ()
@property (nonatomic, strong) GRMustacheTemplate *postTemplate;
- (void)writePosts;
- (NSError *)badDirectoryError;
@end

@implementation TBSite

+ (TBSite *)siteWithRoot:(NSURL *)root {
	TBSite *site = [TBSite new];
	site.root = root;
	site.destination = [site.root URLByAppendingPathComponent:@"Output" isDirectory:YES];
	site.sourceDirectory = [site.root URLByAppendingPathComponent:@"Source" isDirectory:YES];
	site.postsDirectory = [site.root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
	site.templatesDirectory = [site.root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
	NSURL *metadataURL = [site.root URLByAppendingPathComponent:@"Info.plist" isDirectory:NO];
	NSData *metadataData = [NSData dataWithContentsOfURL:metadataURL];
	site.metadata = [NSPropertyListSerialization propertyListFromData:metadataData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
	if (!site.metadata)
		[@{} writeToURL:metadataURL atomically:NO];
	return site;
}

- (void)processWithCompletionHandler:(TBSiteCompletionHandler)handler {
	// Find and compile the post template.
	NSError *error;
	NSURL *defaultTemplateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Default.mustache" isDirectory:NO];
	NSString *rawDefaultTemplate = [NSString stringWithContentsOfURL:defaultTemplateURL encoding:NSUTF8StringEncoding error:nil];
	NSURL *postPartialURL = [self.templatesDirectory URLByAppendingPathComponent:@"Post.mustache" isDirectory:NO];
	NSString *rawPostPartial = [NSString stringWithContentsOfURL:postPartialURL encoding:NSUTF8StringEncoding error:nil];
	NSString *rawPostTemplate = [rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:rawPostPartial];
	self.postTemplate = [GRMustacheTemplate templateFromString:rawPostTemplate error:&error];
    if (!self.postTemplate) {
		handler(error);
		return;
    }
	
	// Take care of posts early so that pages can use them.
	if (![self parsePosts:&error]) {
		handler(error);
		return;
	}
	
	[self writePosts];
	
	// Process the Feed.xml file.
	NSURL *feedTemplateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Feed.mustache"];
	GRMustacheTemplate *feedTemplate = [GRMustacheTemplate templateFromContentsOfURL:feedTemplateURL error:nil];
	NSString *feedContents = [feedTemplate renderObject:self error:nil];
	[feedContents writeToURL:[self.destination URLByAppendingPathComponent:@"feed.xml"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	// Recurse through the entire "Source" directory for pages and files.
	BOOL sourceDirectoryIsDirectory = NO;
	BOOL sourceDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.sourceDirectory.path isDirectory:&sourceDirectoryIsDirectory];
	if (!sourceDirectoryIsDirectory || !sourceDirectoryExists){
		handler([self badDirectoryError]);
		return;
	}
	
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.sourceDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *enumeratorError) {
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
			NSError *pageError;
			TBPage *page = [TBPage pageWithURL:URL inSite:self error:&pageError];
			if (!page) {
				handler(pageError);
				return;
			}
			NSString *rawPageTemplate = [rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:page.content];
			GRMustacheTemplate *pageTemplate = [GRMustacheTemplate templateFromString:rawPageTemplate error:nil];
			NSString *renderedPage = [pageTemplate renderObject:page error:nil];
			destinationURL = [[destinationURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"html"];
			[renderedPage writeToURL:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
			[self runFiltersOnFile:destinationURL];
		}
		else {
			[[NSFileManager defaultManager] copyItemAtURL:URL toURL:destinationURL error:nil];
		}
	}
	handler(nil);
}

- (BOOL)processSynchronously:(NSError **)error {
	__block BOOL finished = NO;
	__block NSError *blockError;
	[self processWithCompletionHandler:^(NSError *asyncError) {
		finished = YES;
		blockError = asyncError;
	}];
	while (!finished) { /* Wait for completion... */ }
	if (error) {
		*error = blockError;
		return NO;
	}
	return YES;
}

- (BOOL)parsePosts:(NSError **)error {
	
	// Verify that the Posts directory exists and is a directory.
	BOOL postsDirectoryIsDirectory = NO;
	BOOL postsDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.postsDirectory.path isDirectory:&postsDirectoryIsDirectory];
	if (!postsDirectoryIsDirectory || !postsDirectoryExists){
        if (error) {
            *error = [self badDirectoryError];
        }
        return NO;
    }
		
	// Parse the contents of the Posts directory into individual TBPost objects.
	NSMutableArray *posts = [NSMutableArray array];
	for (NSURL *postURL in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.postsDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
		TBPost *post = [TBPost postWithURL:postURL inSite:self error:error];
		if (!post) {
			return NO;
		}
		[posts addObject:post];
	}
	posts = [NSMutableArray arrayWithArray:[[posts reverseObjectEnumerator] allObjects]];
	self.posts = posts;
	
    // Prepare the template object tree
    self.templateAssets = [TBAsset assetsFromDirectoryURL:[self templatesDirectory]];
    self.sourceAssets = [TBAsset assetsFromDirectoryURL:[self sourceDirectory]];
    return YES;
	
}
- (void)writePosts {
	
	for (TBPost *post in self.posts) {
		
		post.stylesheets = @[@{@"stylesheetName": @"post"}];
		
		// Create the path to the folder where we are going to write the post file.
		// The directory structure we create is /YYYY/MM/DD/slug/
		NSDateFormatter *postPathFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy/MM/dd"];
		NSString *directoryStructure = [postPathFormatter stringFromDate:post.date];
		NSURL *destinationDirectory = [[self.destination URLByAppendingPathComponent:directoryStructure isDirectory:YES] URLByAppendingPathComponent:post.slug isDirectory:YES];
		[[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		
		// Set up the template loader with this post's content, and then render it all into the post template.
		NSString *renderedContent = [self.postTemplate renderObject:post error:nil];
		
		// Write the post to the destination directory.
		NSURL *destinationURL = [destinationDirectory URLByAppendingPathComponent:@"index.html" isDirectory:NO];
		[renderedContent writeToURL:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		[self runFiltersOnFile:destinationURL];
		
	}
	
}

- (void)runFiltersOnFile:(NSURL *)file {
	
	NSArray *filterPaths = self.metadata[TBSiteFilters];
	if (!filterPaths || ![filterPaths count]) return;
	
	NSURL *scriptsURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationScriptsDirectory inDomains:NSUserDomainMask][0];
	NSArray *arguments = @[file.path];
	
	for (NSString *filterPath in filterPaths) {
		NSURL *filterURL = [scriptsURL URLByAppendingPathComponent:filterPath];
		NSUserUnixTask *filter = [[NSUserUnixTask alloc] initWithURL:filterURL error:nil];
		__block BOOL finished = NO;
		[filter executeWithArguments:arguments completionHandler:^(NSError *error) {
			finished = YES;
		}];
		while (!finished) { /* Wait for completion */ }
	}
	
}

- (NSURL *)addPostWithTitle:(NSString *)title slug:(NSString *)slug error:(NSError **)error{
	NSDate *currentDate = [NSDate date];
	NSDateFormatter *dateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormatter stringFromDate:currentDate];
	NSString *filename = [NSString stringWithFormat:@"%@-%@", dateString, slug];
	NSURL *destination = [[self.postsDirectory URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"md"];
	NSString *contents = [NSString stringWithFormat:@"# %@ #\n\n", title];
	[contents writeToURL:destination atomically:YES encoding:NSUTF8StringEncoding error:nil];
	if (![self parsePosts:error]) {
        return nil;
    }
	return destination;
}

- (NSError *)badDirectoryError{
    NSString *errorString = [NSString stringWithFormat:@"%@ does not exist!", [self.postsDirectory lastPathComponent]];
    NSDictionary *info = @{NSLocalizedDescriptionKey: errorString, NSURLErrorKey: self.postsDirectory};
    NSError *contentError = [NSError errorWithDomain:TBErrorDomain code:TBErrorBadContent userInfo:info];
    return contentError;
}

- (void)setMetadata:(NSDictionary *)metadata {
	_metadata = metadata;
	NSURL *metadataURL = [self.root URLByAppendingPathComponent:@"Info.plist" isDirectory:NO];
	[self.metadata writeToURL:metadataURL atomically:NO];
	if (self.delegate && [self.delegate respondsToSelector:@selector(metadataDidChangeForSite:)])
		[self.delegate metadataDidChangeForSite:self];
}

@end
