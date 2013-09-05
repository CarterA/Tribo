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
#import "TBAsset.h"
#import "TBError.h"
#import "GRMustache.h"
#import "NSDateFormatter+TBAdditions.h"

@interface TBSite ()
@property (nonatomic, strong) GRMustacheTemplate *postTemplate;
@property (nonatomic, strong) NSString *rawDefaultTemplate;
@end

@implementation TBSite

#pragma mark - Initialization

- (instancetype)initWithRoot:(NSURL *)root {
    if (self = [super init]) {
        self.root = root;
        
        self.destination = [root URLByAppendingPathComponent:@"Output" isDirectory:YES];
        self.sourceDirectory = [root URLByAppendingPathComponent:@"Source" isDirectory:YES];
        self.postsDirectory = [root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
        self.templatesDirectory = [root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
        
        NSURL *metadataURL = [root URLByAppendingPathComponent:@"Info.plist" isDirectory:NO];
        NSData *metadataData = [NSData dataWithContentsOfURL:metadataURL];
        
        self.metadata = [NSPropertyListSerialization propertyListFromData:metadataData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
        
        if (!self.metadata) {
            [@{} writeToURL:metadataURL atomically:NO];
        }
    }
    
    return self;
}

#pragma mark - Site Processing

- (BOOL)processIncludingDrafts:(BOOL)includeDrafts error:(NSError **)error {
	if (![self loadRawDefaultTemplate:error])
		return NO;
	
    if (![self loadPostTemplate:error])
		return NO;
	
	if (![self parsePosts:error])
		return NO;
	
	if (![self writePostsIncludingDrafts:includeDrafts error:error])
		return NO;
	
	if (![self writeFeed:error])
		return NO;
	
	if (![self verifySourceDirectory:error])
		return NO;
	
	if (![self processSourceDirectory:error])
		return NO;
	
	return YES;	
}

#pragma mark - Template Loading

- (BOOL)loadRawDefaultTemplate:(NSError **)error {
	NSURL *defaultTemplateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Default.mustache" isDirectory:NO];
    
	self.rawDefaultTemplate = [NSString stringWithContentsOfURL:defaultTemplateURL encoding:NSUTF8StringEncoding error:error];
    
	if (!self.rawDefaultTemplate) {
        return NO;
    }
    
	return YES;
}

- (BOOL)loadPostTemplate:(NSError **)error {
	NSURL *postPartialURL = [self.templatesDirectory URLByAppendingPathComponent:@"Post.mustache" isDirectory:NO];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:postPartialURL.path] == NO) {
        // No post template found
        
		if (error) {
			*error = TBError.missingPostPartial(postPartialURL);
        }
        
		return NO;
	}
    
	NSString *rawPostPartial = [NSString stringWithContentsOfURL:postPartialURL encoding:NSUTF8StringEncoding error:error];
    
	if (!rawPostPartial) {
        // No content in post template
        return NO;
    }
    
	NSString *rawPostTemplate = [self.rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:rawPostPartial];
    
	self.postTemplate = [GRMustacheTemplate templateFromString:rawPostTemplate error:error];
    
	if (!self.postTemplate) {
        // Could not create template
        return NO;
    }
    
	return YES;
}

#pragma mark - Post Processing

- (BOOL)parsePosts:(NSError **)error {
	// Verify that the Posts directory exists and is a directory
	BOOL postsDirectoryIsDirectory = NO;
	BOOL postsDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.postsDirectory.path isDirectory:&postsDirectoryIsDirectory];
    
	if (!postsDirectoryIsDirectory || !postsDirectoryExists) {
        if (error) {
            *error = TBError.missingPostsDirectory(self.postsDirectory);
        }
        
        return NO;
    }
    
	// Parse the contents of the Posts directory into individual TBPost objects
	NSMutableArray *posts = [NSMutableArray array];
	NSArray *postsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.postsDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:error];
    
	if (!postsDirectoryContents) {
        return NO;
    }
    
	for (NSURL *postURL in postsDirectoryContents) {
		TBPost *post = [[TBPost alloc] initWithURL:postURL inSite:self error:error];
		[post parseMarkdownContent];
        
		if (post) {
            [posts addObject:post];
        }
	}
    
	self.posts = [NSMutableArray arrayWithArray:[[posts reverseObjectEnumerator] allObjects]];
	
    // Prepare the asset object tree
    self.templateAssets = [TBAsset assetsFromDirectory:self.templatesDirectory error:error];
    
	if (!self.templateAssets) {
        return NO;
    }
    
    self.sourceAssets = [TBAsset assetsFromDirectory:self.sourceDirectory error:error];
    
	if (!self.sourceAssets) {
        return NO;
    }
	
    return YES;
	
}

- (BOOL)writePostsIncludingDrafts:(BOOL)includeDrafts error:(NSError **)error {
	for (TBPost *post in self.posts) {
        if (includeDrafts && post.draft) {
            continue;
        }
        
		post.stylesheets = @[@{@"stylesheetName": @"post"}];
		
		// Create the path to the folder where we are going to write the post file
		// The directory structure we create is /YYYY/MM/DD/slug/
        
		NSDateFormatter *postPathFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy/MM/dd"];
		NSString *directoryStructure = [postPathFormatter stringFromDate:post.date];
        
		NSURL *destinationDirectory = [[self.destination URLByAppendingPathComponent:directoryStructure isDirectory:YES] URLByAppendingPathComponent:post.slug isDirectory:YES];
        
        // Create the destination directory
		if ([[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:error] == NO)
			return NO;
		
		// Filter the markdownContent of the post
		NSString *originalContent = post.markdownContent;
        
		NSString *filteredMarkdownContent = [self filteredContent:(originalContent ?: @"") fromFile:post.URL error:error];
        
		if (!filteredMarkdownContent) {
			return NO;
        }
        
		post.markdownContent = filteredMarkdownContent;
        
		[post parseMarkdownContent];
        
		post.markdownContent = originalContent;
		
		// Set up the template loader with this post's content, and then render it all into the post template
		NSString *renderedContent = [self.postTemplate renderObject:post error:error];
        
		if (!renderedContent) {
			return NO;
        }
		
		// Write the post to the destination directory.
		NSURL *destinationURL = [destinationDirectory URLByAppendingPathComponent:@"index.html" isDirectory:NO];
        
		if (![renderedContent writeToURL:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:error]) {
            // Could not write index.html
            return NO;
        }
	}
	
	return YES;
	
}

#pragma mark - Feed Processing

- (BOOL)writeFeed:(NSError **)error {
	NSURL *templateURL = [self.templatesDirectory URLByAppendingPathComponent:@"Feed.mustache"];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:templateURL.path] == NO) {
        // Could not find feed template
        return YES;
    }
    
	GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:templateURL error:error];
    
	if (!template) {
        return NO;
    }
    
	NSString *contents = [template renderObject:self error:error];
    
	if (!contents) {
        return NO;
    }
    
	NSURL *destination = [self.destination URLByAppendingPathComponent:@"feed.xml"];
    
	if (![contents writeToURL:destination atomically:YES encoding:NSUTF8StringEncoding error:error]) {
        // Could not write feed.xml
		return NO;
    }
    
	return YES;
}

#pragma mark - Source Directory Processing

- (BOOL)verifySourceDirectory:(NSError **)error {
	BOOL sourceDirectoryIsDirectory = NO;
	BOOL sourceDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:self.sourceDirectory.path isDirectory:&sourceDirectoryIsDirectory];
    
	if (!sourceDirectoryIsDirectory || !sourceDirectoryExists) {
		if (error) {
            *error = TBError.missingSourceDirectory(self.sourceDirectory);
        }
        
		return NO;
	}
    
	return YES;
}

- (BOOL)processSourceDirectory:(NSError **)error {
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.sourceDirectory
                                                             includingPropertiesForKeys:nil
                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           errorHandler:^BOOL(NSURL *url, NSError *enumeratorError) {
		return YES;
	}];
    
	for (NSURL *URL in enumerator) {
		BOOL URLIsDirectory = NO;
        
		[[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&URLIsDirectory];
        
		if (URLIsDirectory) {
            continue;
        }
		
		if (![self processSourceFile:URL error:error]) {
			return NO;
        }
	}
    
	return YES;
}

- (BOOL)processSourceFile:(NSURL *)URL error:(NSError **)error {
	NSString *extension = [URL pathExtension];
	NSString *relativePath = [URL.path stringByReplacingOccurrencesOfString:self.sourceDirectory.path withString:@""];
    
	NSURL *destinationURL = [[self.destination URLByAppendingPathComponent:relativePath] URLByStandardizingPath];
	NSURL *destinationDirectory = [destinationURL URLByDeletingLastPathComponent];
    
	if (![[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectory withIntermediateDirectories:YES attributes:nil error:error]) {
        // Unable to create directory structure
		return NO;
    }
    
	[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
	
	if ([extension isEqualToString:@"mustache"]) {
		TBPage *page = [[TBPage alloc] initWithURL:URL inSite:self error:nil];
        
		NSURL *pageDestination = [[destinationURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"html"];
        
		if (![self writePage:page toDestination:pageDestination error:error]) {
			return NO;
        }
	} else {
        // Not a mustache file, copy without processing
		[[NSFileManager defaultManager] copyItemAtURL:URL toURL:destinationURL error:error];
    }
    
	return YES;
}

- (BOOL)writePage:(TBPage *)page toDestination:(NSURL *)destination error:(NSError **)error {
	if (!page) {
        return NO;
    }
    
	NSString *rawPageTemplate = [self.rawDefaultTemplate stringByReplacingOccurrencesOfString:@"{{{content}}}" withString:page.content];
    
	GRMustacheTemplate *pageTemplate = [GRMustacheTemplate templateFromString:rawPageTemplate error:error];
    
	if (!pageTemplate) {
        return NO;
    }
    
	NSString *renderedPage = [pageTemplate renderObject:page error:error];
    
	if (!renderedPage) {
        return NO;
    }
    
	if (![renderedPage writeToURL:destination atomically:YES encoding:NSUTF8StringEncoding error:error]) {
		return NO;
    }
    
	return YES;
}

#pragma mark - Filters

- (NSString *)filteredContent:(NSString *)content fromFile:(NSURL *)file error:(NSError **)error {
	NSArray *filterPaths = self.metadata[TBSiteFilters];
    
	if (!filterPaths || ![filterPaths count]) {
		return content;
    }
	
	NSURL *scriptsURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationScriptsDirectory inDomains:NSUserDomainMask][0];
	NSArray *arguments = @[self.root.path, file.path];
	
	for (NSString *filterPath in filterPaths) {
		NSURL *filterURL = [scriptsURL URLByAppendingPathComponent:filterPath];
        
		NSUserUnixTask *filter = [[NSUserUnixTask alloc] initWithURL:filterURL error:error];
        
		if (!filter) {
            return content;
        }
		
		NSPipe *standardError = [NSPipe pipe];
        NSPipe *standardInput = [NSPipe pipe];
        NSPipe *standardOutput = [NSPipe pipe];
        
		filter.standardError = standardError.fileHandleForWriting;
		filter.standardInput = standardInput.fileHandleForReading;
		filter.standardOutput = standardOutput.fileHandleForWriting;
        
		[standardInput.fileHandleForWriting writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
		[standardInput.fileHandleForWriting closeFile];
		
		__block NSError *blockError = nil;
		dispatch_group_t group = dispatch_group_create();
        
		dispatch_async(dispatch_get_current_queue(), ^{
			dispatch_group_enter(group);
            
			[filter executeWithArguments:arguments completionHandler:^(NSError *filterError) {
				blockError = filterError;
                
				dispatch_group_leave(group);
			}];
		});
        
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
		if (blockError) {
			if (error) {
                *error = blockError;
            }
            
			return nil;
		}
		
		NSData *standardErrorData = [standardError.fileHandleForReading readDataToEndOfFile];
        
		if (standardErrorData.length > 0) {
			NSString *standardErrorContents = [NSString stringWithUTF8String:standardErrorData.bytes];
            
			if (error) {
                *error = TBError.filterStandardError(filterURL, standardErrorContents);
            }
            
			return nil;
		}
        
		NSData *standardOutputData = [standardOutput.fileHandleForReading readDataToEndOfFile];
        
		if (standardOutputData.length > 0) {
			content = [[NSString alloc] initWithBytes:standardOutputData.bytes length:standardOutputData.length encoding:NSUTF8StringEncoding];
        }
	}
	
	return content;
}

#pragma mark - Site Modification

- (void)addPost:(TBPost *)post {
    [self.posts addObject:post];
}

- (void)setMetadata:(NSDictionary *)metadata {
	_metadata = metadata;
    
	NSURL *metadataURL = [self.root URLByAppendingPathComponent:@"Info.plist" isDirectory:NO];
    
	[self.metadata writeToURL:metadataURL atomically:NO];
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(metadataDidChangeForSite:)]) {
		[self.delegate metadataDidChangeForSite:self];
    }
}

@end
