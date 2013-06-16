//
//  NSDateFormatter+TBAdditions.m
//  Tribo
//
//  Created by Carter Allen on 6/15/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import "NSDateFormatter+TBAdditions.h"

NSString * const TBDateFormatterCachePrefix = @"TBDateFormatter:";

@implementation NSDateFormatter (TBAdditions)

+ (instancetype)tb_cachedDateFormatterFromString:(NSString *)format {
	NSString *cacheKey = [TBDateFormatterCachePrefix stringByAppendingString:format];
	NSDateFormatter *dateFormatter = [[self tb_dateFormatterCache] objectForKey:cacheKey];
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = format;
		[[self tb_dateFormatterCache] setObject:dateFormatter forKey:cacheKey];
	}
	return dateFormatter;
}

+ (NSCache *)tb_dateFormatterCache {
	static NSCache *TBDateFormatterCache;
	if (!TBDateFormatterCache)
		TBDateFormatterCache = [NSCache new];
	return TBDateFormatterCache;
}

@end
