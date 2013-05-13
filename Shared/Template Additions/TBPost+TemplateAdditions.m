//
//  TBPost+TemplateAdditions.m
//  Tribo
//
//  Created by Carter Allen on 5/13/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPost+TemplateAdditions.h"

@implementation TBPost (TemplateAdditions)
- (NSString *)dateString {
	static NSDateFormatter *dateStringFormatter;
	if (dateStringFormatter == nil) {
		dateStringFormatter = [NSDateFormatter new];
		dateStringFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMMyyyy" options:0 locale:[NSLocale currentLocale]];
	}
	return [dateStringFormatter stringFromDate:self.date];
}
- (NSString *)XMLDate {
	static NSDateFormatter *XMLDateFormatter;
	if (XMLDateFormatter == nil) {
		XMLDateFormatter = [NSDateFormatter new];
		XMLDateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
	}
	NSMutableString *mutableDateString = [[XMLDateFormatter stringFromDate:self.date] mutableCopy];
	[mutableDateString insertString:@":" atIndex:mutableDateString.length - 2];
	return mutableDateString;
}
- (NSString *)summary {
	NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
	[self.content getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(0, 0)];
	NSRange paragraphRange = NSMakeRange(paraStart, contentsEnd - paraStart);
	return [self.content substringWithRange:paragraphRange];
}
- (NSString *)relativeURL {
	static NSDateFormatter *relativeURLFormatter;
	if (relativeURLFormatter == nil) {
		relativeURLFormatter = [NSDateFormatter new];
		relativeURLFormatter.dateFormat = @"/yyyy/MM/dd";
	}
	NSString *directoryStructure = [relativeURLFormatter stringFromDate:self.date];
	return [directoryStructure stringByAppendingPathComponent:self.slug];
}
@end
