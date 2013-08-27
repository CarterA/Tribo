//
//  TBPost.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSite.h"
#import "TBPost.h"
#import "TBError.h"
#import "markdown.h"
#import "html.h"
#import "NSDateFormatter+TBAdditions.h"

@implementation TBPost

- (instancetype)initWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError **)error {
	return [super initWithURL:URL inSite:site error:error];
}

- (instancetype)initWithTitle:(NSString *)title slug:(NSString *)slug inSite:(TBSite *)site error:(NSError **)error {
    if (self = [super init]) {
        self.site = site;
        
        // Create the directory
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd"];
        
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        
        NSString *filename = [NSString stringWithFormat:@"%@-%@", dateString, slug];
        
        self.postDirectory = [site.postsDirectory URLByAppendingPathComponent:slug isDirectory:YES];
        
        if (![[NSFileManager defaultManager] createDirectoryAtURL:self.postDirectory withIntermediateDirectories:YES attributes:nil error:error]) {
            // Unable to create directory structure
            return nil;
        }
        
        // Metadata File
        self.metadata = [[TSPostMetadata alloc] initWithPostDirectory:self.postDirectory];
        
        [self.metadata writeWithError:error];
        
        // Post File
        NSURL *contentDestination = [[self.postDirectory URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"md"];
        
        NSString *contents = [NSString stringWithFormat:@"# %@ #\n\n", title];
        
        if (![contents writeToURL:contentDestination atomically:YES encoding:NSUTF8StringEncoding error:error]) {
            return nil;
        }
        
        self.URL = contentDestination;
        
        [self parse:error];
    }
    
    return self;
}

- (BOOL)parse:(NSError **)error {	
	if (![self parseDateAndSlug:error]) {
		return NO;
    }
    
    [self loadMarkdownContent];
	[self parseTitle];
	
    return YES;
	
}

- (void)loadMarkdownContent {
	self.markdownContent = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:nil];
}

/*!
 * Extracts the title from the markdown contents.
 *
 * Titles are optional.
 * Titles are defined as a single '#' header on the first line of the document.
 * Title must have '#' on both sides, e.g. '# Title of Post #'
 */
- (void)parseTitle {
	if (!self.markdownContent || ![self.markdownContent length]) {
        // No markdown content found, return
        return;
    }
    
	NSMutableString *markdownContent = [self.markdownContent mutableCopy];
    
	static NSRegularExpression *headerRegex;
    
	if (headerRegex == nil) {
		headerRegex = [NSRegularExpression regularExpressionWithPattern:@"#[ \\t](.*)[ \\t]#" options:0 error:nil];
    }
    
	NSRange firstLineRange = NSMakeRange(0, [markdownContent rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location);
    
	if (firstLineRange.length == NSNotFound) {
        // Can't find a first header
        return;
    }
    
	NSString *firstLine = [markdownContent substringWithRange:firstLineRange];
    
	NSTextCheckingResult *titleResult = [headerRegex firstMatchInString:firstLine options:0 range:NSMakeRange(0, firstLine.length)];
    
	if (titleResult) {
		self.title = [firstLine substringWithRange:[titleResult rangeAtIndex:1]];
        
		[markdownContent deleteCharactersInRange:NSMakeRange(firstLineRange.location, firstLineRange.length + 1)];
	}
    
    // Remove the first new line after the title from the content
	[markdownContent deleteCharactersInRange:[markdownContent rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]]];
    
	self.markdownContent = markdownContent;
}

- (BOOL)parseDateAndSlug:(NSError **)error {
	// Dates and slugs are parsed from a pattern in the post file name
	static NSRegularExpression *fileNameRegex;
    
	if (fileNameRegex == nil) {
		fileNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d+-\\d+-\\d+)-(.*)" options:0 error:nil];
    }
    
	NSString *fileName = [self.URL.lastPathComponent stringByDeletingPathExtension];
    
	NSTextCheckingResult *fileNameResult = [fileNameRegex firstMatchInString:fileName options:0 range:NSMakeRange(0, fileName.length)];
    
	if (fileNameResult) {
		NSDateFormatter *fileNameDateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd"];
        
		self.date = [fileNameDateFormatter dateFromString:[fileName substringWithRange:[fileNameResult rangeAtIndex:1]]];
		self.slug = [fileName substringWithRange:[fileNameResult rangeAtIndex:2]];
	} else {
        // No date found
        
		if (error) {
            *error = TBError.badPostFileName(self.URL);
        }
        
		return NO;
	}
    
	return YES;
}

- (void)parseMarkdownContent {
	if (!self.markdownContent || ![self.markdownContent length]) {
        // No markdown content found, return
        return;
    }
    
	// Create and fill a buffer for with the raw markdown data
	struct sd_callbacks callbacks;
	struct html_renderopt options;
    
	const char *rawMarkdown = [self.markdownContent cStringUsingEncoding:NSUTF8StringEncoding];
	struct buf *smartyPantsOutputBuffer = bufnew(1);
    
	sdhtml_smartypants(smartyPantsOutputBuffer, (const unsigned char *)rawMarkdown, strlen(rawMarkdown));
	
	// Parse the markdown into a new buffer using Sundown
	struct buf *outputBuffer = bufnew(64);
    
	sdhtml_renderer(&callbacks, &options, 0);
    
	struct sd_markdown *markdown = sd_markdown_new(0, 16, &callbacks, &options);
    
	sd_markdown_render(outputBuffer, smartyPantsOutputBuffer->data, smartyPantsOutputBuffer->size, markdown);
	sd_markdown_free(markdown);
	
	self.content = @(bufcstr(outputBuffer));
	
	bufrelease(smartyPantsOutputBuffer);
	bufrelease(outputBuffer);
}

@end
