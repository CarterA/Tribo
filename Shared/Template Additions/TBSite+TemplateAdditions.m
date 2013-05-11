//
//  TBSite+TemplateAdditions.m
//  Tribo
//
//  Created by Carter Allen on 5/11/13.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//


#import "TBSite+TemplateAdditions.h"

@implementation TBSite (TemplateAdditions)
- (TBPost *)latestPost {
	return self.posts[0];
}
- (NSArray *)recentPosts {
	if ([self.posts count] == 0) return @[];
	NSUInteger recentPostCount = [self.metadata[TBSiteNumberOfRecentPostsMetadataKey] unsignedIntegerValue];
	if (!recentPostCount) recentPostCount = 5;
	if ([self.posts count] < recentPostCount) recentPostCount = [self.posts count];
	return [self.posts subarrayWithRange:NSMakeRange(0, recentPostCount)];
}
- (NSString *)XMLDate {
	NSDate *date = [NSDate date];
	static NSDateFormatter *XMLDateFormatter;
	if (XMLDateFormatter == nil) {
		XMLDateFormatter = [NSDateFormatter new];
		XMLDateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
	}
	NSMutableString *mutableDateString = [[XMLDateFormatter stringFromDate:date] mutableCopy];
	[mutableDateString insertString:@":" atIndex:mutableDateString.length - 2];
	return mutableDateString;
}
- (NSString *)name {
	return [self.metadata objectForKey:TBSiteNameMetadataKey];
}
- (NSString *)author {
	return [self.metadata objectForKey:TBSiteAuthorMetadataKey];
}
- (NSString *)baseURL {
	return [self.metadata objectForKey:TBSiteBaseURLMetadataKey];
}
@end
