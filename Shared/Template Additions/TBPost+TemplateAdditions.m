//
//  TBPost+TemplateAdditions.m
//  Tribo
//
//  Created by Carter Allen on 5/13/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPost+TemplateAdditions.h"
#import "NSDateFormatter+TBAdditions.h"

@implementation TBPost (TemplateAdditions)
- (NSString *)dateString {
	NSDateFormatter *dateStringFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd hh:mm a z"];
	return [dateStringFormatter stringFromDate:self.date];
}
- (NSString *)XMLDate {
	NSDateFormatter *XMLDateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
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
	NSDateFormatter *relativeURLFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"/yyyy/MM/dd"];
	NSString *directoryStructure = [relativeURLFormatter stringFromDate:self.date];
	return [directoryStructure stringByAppendingPathComponent:self.slug];
}
@end
