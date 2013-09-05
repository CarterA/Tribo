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

+ (instancetype)postWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError **)error {
    NSString *slug = [URL lastPathComponent];
    
    NSURL *postURL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.md", slug]];
    
    TBPost *post = [super pageWithURL:postURL inSite:site error:error];
    
    if (post) {
        post.postDirectory = URL;
        
        post.slug = slug;
        
        post.metadata = [[TBPostMetadata alloc] initWithPostDirectory:URL withError:error];
        
        if (post.metadata) {
            return post;
        }
        
        return nil;
    }
    
    return nil;
}

- (instancetype)initWithTitle:(NSString *)title slug:(NSString *)slug inSite:(TBSite *)site error:(NSError **)error {
    if (self = [super init]) {
        self.site = site;
        
        // Create the directory
        NSString *filename = [NSString stringWithString:slug];
        
        self.postDirectory = [site.postsDirectory URLByAppendingPathComponent:slug isDirectory:YES];
        
        if (![[NSFileManager defaultManager] createDirectoryAtURL:self.postDirectory withIntermediateDirectories:YES attributes:nil error:error]) {
            // Unable to create directory structure
            return nil;
        }
        
        // Metadata File
        self.metadata = [[TBPostMetadata alloc] initWithPostDirectory:self.postDirectory withError:error];
        
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
    [self loadMarkdownContent];
    
	if (![self parseSlug:error]) {
		return NO;
    }
	
	[self parseTitle];
	
    return YES;
	
}

- (void)loadMarkdownContent; {
	NSString *markdownContent = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:nil];
	self.markdownContent = markdownContent;
}

- (void)parseTitle {
	// Titles are optional. A single # header on the first line of the document is regarded as the title.
	if (!self.markdownContent || ![self.markdownContent length]) return;
	NSMutableString *markdownContent = [self.markdownContent mutableCopy];
	static NSRegularExpression *headerRegex;
	if (headerRegex == nil)
		headerRegex = [NSRegularExpression regularExpressionWithPattern:@"#[ \\t](.*)[ \\t]#" options:0 error:nil];
	NSRange firstLineRange = NSMakeRange(0, [markdownContent rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location);
	if (firstLineRange.length == NSNotFound) return;
	NSString *firstLine = [markdownContent substringWithRange:firstLineRange];
	NSTextCheckingResult *titleResult = [headerRegex firstMatchInString:firstLine options:0 range:NSMakeRange(0, firstLine.length)];
	if (titleResult) {
		self.title = [firstLine substringWithRange:[titleResult rangeAtIndex:1]];
		[markdownContent deleteCharactersInRange:NSMakeRange(firstLineRange.location, firstLineRange.length + 1)];
	}
	[markdownContent deleteCharactersInRange:[markdownContent rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]]];
	self.markdownContent = markdownContent;
}

- (BOOL)parseSlug:(NSError **)error {
	NSString *filename = [[self.URL lastPathComponent] stringByDeletingPathExtension];
    
    if (filename && [filename length] > 0) {
        self.slug = filename;
        
        return YES;
    }
    
    return NO;
}

- (void)parseMarkdownContent {
	if (!self.markdownContent || ![self.markdownContent length]) return;
	// Create and fill a buffer for with the raw markdown data.
	if ([self.markdownContent length] == 0) return;
	struct sd_callbacks callbacks;
	struct html_renderopt options;
	const char *rawMarkdown = [self.markdownContent cStringUsingEncoding:NSUTF8StringEncoding];
	struct buf *smartyPantsOutputBuffer = bufnew(1);
	sdhtml_smartypants(smartyPantsOutputBuffer, (const unsigned char *)rawMarkdown, strlen(rawMarkdown));
	
	// Parse the markdown into a new buffer using Sundown.
	struct buf *outputBuffer = bufnew(64);
	sdhtml_renderer(&callbacks, &options, 0);
	struct sd_markdown *markdown = sd_markdown_new(0, 16, &callbacks, &options);
	sd_markdown_render(outputBuffer, smartyPantsOutputBuffer->data, smartyPantsOutputBuffer->size, markdown);
	sd_markdown_free(markdown);
	
	self.content = @(bufcstr(outputBuffer));
	
	bufrelease(smartyPantsOutputBuffer);
	bufrelease(outputBuffer);
}

- (NSDate *)date {
    return [self.metadata publishedDate];
}

- (BOOL)draft {
    return [self.metadata draft];
}

- (void)setDraft:(BOOL)draft {
    [self.metadata setDraft:draft];
    
    if (draft == NO) {
        [self.metadata setPublishedDate:[NSDate date]];
    } else {
        [self.metadata setPublishedDate:nil];
    }
    
    NSError *error = nil;
    
    [self.metadata writeWithError:&error];
    
    if (error) {
        [self.metadata setDraft:!draft];
        [self.metadata setPublishedDate:nil];
    }
}

@end
