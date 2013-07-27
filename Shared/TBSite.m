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
@property (nonatomic, strong) NSString *rawDefaultTemplate;
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
	
	NSError *error;
	
	if (![self loadRawDefaultTemplate:&error]) {
		handler(error);
		return;
	}
	
    if (![self loadPostTemplate:&error]) {
		handler(error);
		return;
    }
	
	if (![self parsePosts:&error]) {
		handler(error);
		return;
	}
	
	if (![self writePosts:&error]) {
		handler(error);
		return;
	}
	
	if (![self writeFeed:&error]) {
		handler(error);
		return;
	}
	
	if (![self verifySourceDirectory:&error]) {
		handler(error);
		return;
	}
	
	if (![self processSourceDirectory:&error]) {
		handler(error);
		return;
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

- (BOOL)loadRawDefaultTemplate:(NSError **)error {
	NSURL *defaultTemplateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Default.mustache" isDirectory:NO];
	self.rawDefaultTemplate = [NSString stringWithContentsOfURL:defaultTemplateURL encoding:NSUTF8StringEncoding error:error];
	if (!self.rawDefaultTemplate) return NO;
	return YES;
}

- (BOOL)loadPostTemplate:(NSError **)error {
	NSURL *postPartialURL = [self.templatesDirectory URLByAppendingPathComponent:@"Post.mustache" isDirectory:NO];
	if (![[NSFileManager defaultManager] fileExistsAtPath:postPartialURL.path]) {
		if (error)
			*error = [NSError errorWithDomain:TBErrorDomain code:TBErrorMissingPostPartial userInfo:nil];
		return NO;
	}
	NSString *rawPostPartial = [NSString stringWithContentsOfURL:postPartialURL encoding:NSUTF8StringEncoding error:error];
	if (!rawPostPartial) return NO;
	NSString *rawPostTemplate = [self.rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:rawPostPartial];
	self.postTemplate = [GRMustacheTemplate templateFromString:rawPostTemplate error:error];
	if (!self.postTemplate) return NO;
	return YES;
}

- (BOOL)parsePosts:(NSError **)error {
	
	// Verify that the Posts directory exists and is a directory.
	BOOL postsDirectoryIsDirectory = NO;
	BOOL postsDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.postsDirectory.path isDirectory:&postsDirectoryIsDirectory];
	if (!postsDirectoryIsDirectory || !postsDirectoryExists){
        if (error) {
            *error = [NSError errorWithDomain:TBErrorDomain code:TBErrorMissingPostDirectory userInfo:nil];
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

- (BOOL)writePosts:(NSError **)error {
	
	for (TBPost *post in self.posts) {
		
		post.stylesheets = @[@{@"stylesheetName": @"post"}];
		
		// Create the path to the folder where we are going to write the post file.
		// The directory structure we create is /YYYY/MM/DD/slug/
		NSDateFormatter *postPathFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy/MM/dd"];
		NSString *directoryStructure = [postPathFormatter stringFromDate:post.date];
		NSURL *destinationDirectory = [[self.destination URLByAppendingPathComponent:directoryStructure isDirectory:YES] URLByAppendingPathComponent:post.slug isDirectory:YES];
		if (![[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:error])
			return NO;
		
		// Set up the template loader with this post's content, and then render it all into the post template.
		NSString *renderedContent = [self.postTemplate renderObject:post error:error];
		if (!renderedContent) return NO;
		
		// Write the post to the destination directory.
		NSURL *destinationURL = [destinationDirectory URLByAppendingPathComponent:@"index.html" isDirectory:NO];
		if (![renderedContent writeToURL:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:error])
			return NO;
		
		if (![self runFiltersOnFile:destinationURL error:error])
			return NO;
		
	}
	
	return YES;
	
}

- (BOOL)writeFeed:(NSError **)error {
	NSURL *templateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Feed.mustache"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:templateURL.path]) return YES;
	GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:templateURL error:error];
	if (!template) return NO;
	NSString *contents = [template renderObject:self error:error];
	if (!contents) return NO;
	NSURL *destination = [self.destination URLByAppendingPathComponent:@"feed.xml"];
	if (![contents writeToURL:destination atomically:YES encoding:NSUTF8StringEncoding error:error])
		return NO;
	return YES;
}

- (BOOL)verifySourceDirectory:(NSError **)error {
	BOOL sourceDirectoryIsDirectory = NO;
	BOOL sourceDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.sourceDirectory.path isDirectory:&sourceDirectoryIsDirectory];
	if (!sourceDirectoryIsDirectory || !sourceDirectoryExists){
		if (error)
			*error = [NSError errorWithDomain:TBErrorDomain code:TBErrorBadSourceDirectory userInfo:nil];
		return NO;
	}
	return YES;
}

- (BOOL)processSourceDirectory:(NSError **)error {
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.sourceDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *enumeratorError) {
		return YES;
	}];
	for (NSURL *URL in enumerator) {
		
		BOOL URLIsDirectory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&URLIsDirectory];
		if (URLIsDirectory) continue;
		
		if (![self processSourceFile:URL error:error])
			return NO;
		
	}
	return YES;
}

- (BOOL)processSourceFile:(NSURL *)URL error:(NSError **)error {
	NSString *extension = [URL pathExtension];
	NSString *relativePath = [URL.path stringByReplacingOccurrencesOfString:self.sourceDirectory.path withString:@""];
	NSURL *destinationURL = [[self.destination URLByAppendingPathComponent:relativePath] URLByStandardizingPath];
	NSURL *destinationDirectory = [destinationURL URLByDeletingLastPathComponent];
	if (![[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:error])
		return NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path])
		if (![[NSFileManager defaultManager] removeItemAtURL:destinationURL error:error])
			return NO;
	
	if ([extension isEqualToString:@"mustache"]) {
		TBPage *page = [TBPage pageWithURL:URL inSite:self error:error];
		if (!page) return NO;
		NSURL *pageDestination = [[destinationURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"html"];
		if (![self writePage:page toDestination:pageDestination error:error])
			return NO;
	}
	else {
		if (![[NSFileManager defaultManager] copyItemAtURL:URL toURL:destinationURL error:error])
			return NO;
	}
	return YES;
}

- (BOOL)writePage:(TBPage *)page toDestination:(NSURL *)destination error:(NSError **)error {
	if (!page) return NO;
	NSString *rawPageTemplate = [self.rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:page.content];
	GRMustacheTemplate *pageTemplate = [GRMustacheTemplate templateFromString:rawPageTemplate error:error];
	if (!pageTemplate) return NO;
	NSString *renderedPage = [pageTemplate renderObject:page error:error];
	if (!renderedPage) return NO;
	if (![renderedPage writeToURL:destination atomically:YES encoding:NSUTF8StringEncoding error:error])
		return NO;
	if (![self runFiltersOnFile:destination error:error])
		return NO;
	return YES;
}

- (BOOL)runFiltersOnFile:(NSURL *)file error:(NSError **)error {
	
	NSArray *filterPaths = self.metadata[TBSiteFilters];
	if (!filterPaths || ![filterPaths count]) return YES;
	
	NSURL *scriptsURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationScriptsDirectory inDomains:NSUserDomainMask][0];
	NSArray *arguments = @[file.path];
	
	for (NSString *filterPath in filterPaths) {
		NSURL *filterURL = [scriptsURL URLByAppendingPathComponent:filterPath];
		NSUserUnixTask *filter = [[NSUserUnixTask alloc] initWithURL:filterURL error:nil];
		NSPipe *standardError = [NSPipe pipe];
		filter.standardError = standardError.fileHandleForWriting;
		__block BOOL finished = NO;
		__block NSError *blockError;
		[filter executeWithArguments:arguments completionHandler:^(NSError *filterError) {
			blockError = filterError;
			finished = YES;
		}];
		while (!finished) { /* Wait for completion */ }
		if (blockError) {
			if (error) *error = blockError;
			return NO;
		}
		NSString *standardErrorContents = [NSString stringWithUTF8String:[standardError.fileHandleForReading readDataToEndOfFile].bytes];
		if (standardErrorContents.length > 0) {
			NSError *filterError = [NSError errorWithDomain:TBErrorDomain code:TBErrorFilterStandardError userInfo:
									@{NSLocalizedDescriptionKey: standardErrorContents}];
			if (error) *error = filterError;
			return NO;
		}
	}
	
	return YES;
	
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

- (void)setMetadata:(NSDictionary *)metadata {
	_metadata = metadata;
	NSURL *metadataURL = [self.root URLByAppendingPathComponent:@"Info.plist" isDirectory:NO];
	[self.metadata writeToURL:metadataURL atomically:NO];
	if (self.delegate && [self.delegate respondsToSelector:@selector(metadataDidChangeForSite:)])
		[self.delegate metadataDidChangeForSite:self];
}

@end
