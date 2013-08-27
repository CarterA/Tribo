//
//  TBPage.m
//  Tribo
//
//  Created by Carter Allen on 9/30/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPage.h"

@implementation TBPage

- (instancetype)initWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError **)error {
    if (self = [super init]) {
		self.URL = URL;
		self.site = site;
        
		[self parse:error];
	}
    
	return self;
}

- (BOOL)parse:(NSError **)error {
	[self loadContent];
	[self parseTitle];
	[self parseStylesheets];
    
	return YES;
}

- (void)loadContent {
	self.content = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:nil];
}

/*!
 * Parse the title from the content.
 *
 * Titles are optional.
 * They take the following form:
 *     <!-- Title -->
 */
- (void)parseTitle {
	if (!self.content || ![self.content length]) {
        // No content found, return
        return;
    }
    
	NSMutableString *content = [self.content mutableCopy];
    
	NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"<!--[ \\t](.*)[ \\t]-->" options:0 error:nil];
    
	NSRange firstLineRange = NSMakeRange(0, [content rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location);
	NSString *firstLine = [content substringWithRange:firstLineRange];
    
	NSTextCheckingResult *titleResult = [headerRegex firstMatchInString:firstLine options:0 range:NSMakeRange(0, firstLine.length)];
    
	if (titleResult) {
        // Found the title!
		self.title = [firstLine substringWithRange:[titleResult rangeAtIndex:1]];
        
		[content deleteCharactersInRange:NSMakeRange(firstLineRange.location, firstLineRange.length + 1)];
	}
    
	self.content = content;
}

/*!
 * Parse the stylesheet from the content.
 *
 * Stylesheets are optional.
 * They take the following form:
 *      <!-- Stylesheets: name, name -->
 *
 * They are the second line in the file if there is a title; first if there is not a title.
 */
- (void)parseStylesheets {
	if (!self.content || ![self.content length]) {
        return;
    }
    
	NSMutableString *content = [self.content mutableCopy];
    
	NSRegularExpression *stylesheetsRegex = [NSRegularExpression regularExpressionWithPattern:@"<!-- Stylesheets:[ \\t](.*)[ \\t]-->" options:0 error:nil];
    
	NSRange secondLineRange = NSMakeRange(0, [content rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location);
	NSString *secondLine = [content substringWithRange:secondLineRange];
    
	NSTextCheckingResult *stylesheetsResult = [stylesheetsRegex firstMatchInString:secondLine options:0 range:NSMakeRange(0, secondLine.length)];
    
	if (stylesheetsResult) {
		NSString *rawMatch = [secondLine substringWithRange:[stylesheetsResult rangeAtIndex:1]];
        
		NSArray *stylesheetNames = [rawMatch componentsSeparatedByString:@", "];
        
		NSMutableArray *stylesheetDictionaries = [NSMutableArray array];
        
		for (NSString *stylesheetName in stylesheetNames) {
			[stylesheetDictionaries addObject:@{@"stylesheetName": stylesheetName}];
		}
        
		self.stylesheets = stylesheetDictionaries;
        
		[content deleteCharactersInRange:secondLineRange];
	}
    
	self.content = content;
}

@end
