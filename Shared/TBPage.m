//
//  TBPage.m
//  Tribo
//
//  Created by Carter Allen on 9/30/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPage.h"
#import "TBError.h"

@implementation TBPage

+ (instancetype)pageWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError**)error{
	TBPage *page = [super new];
	if (page) {
		page.URL = URL;
		page.site = site;
        
		BOOL parsedPage = [page parse:error];
        if (!parsedPage) {
            return nil;
        }
	}
	return page;
}

- (BOOL)parse:(NSError **)error{
	
	if (![self loadContent:error])
		return NO;
	
	[self parseTitle];
	
	[self parseStylesheets];
	
	return YES;
}

- (BOOL)loadContent:(NSError **)error {
	NSString *content = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:error];
	if (!content.length) {
		if (error) *error = TBError.emptyPageFile(self.URL);
		return NO;
	}
	self.content = content;
	return YES;
}

- (void)parseTitle {
	// Titles are optional. They take the following form:
	// <!-- Title -->
	NSMutableString *content = [self.content mutableCopy];
	NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"<!--[ \\t](.*)[ \\t]-->" options:0 error:nil];
	NSRange firstLineRange = NSMakeRange(0, [content rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location);
	NSString *firstLine = [content substringWithRange:firstLineRange];
	NSTextCheckingResult *titleResult = [headerRegex firstMatchInString:firstLine options:0 range:NSMakeRange(0, firstLine.length)];
	if (titleResult) {
		self.title = [firstLine substringWithRange:[titleResult rangeAtIndex:1]];
		[content deleteCharactersInRange:NSMakeRange(firstLineRange.location, firstLineRange.length + 1)];
	}
	self.content = content;
}

- (void)parseStylesheets {
	// Stylsheets are also optional. They are on the second line (or first if there is no title), and look like this:
	// <!-- Stylsheets: name, name -->
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
