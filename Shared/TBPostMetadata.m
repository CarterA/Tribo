//
//  TSPostMetadata.m
//  Tribo
//
//  Created by Tanner Smith on 8/27/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPostMetadata.h"

#import "NSDateFormatter+TBAdditions.h"

@implementation TBPostMetadata

@synthesize draft, publishedDate;
@synthesize postDirectory;

- (instancetype)init {
    if (self = [super init]) {
        draft = YES;
        
        publishedDate = nil;
    }
    
    return self;
}

- (instancetype)initWithPostDirectory:(NSURL *)directory withError:(NSError **)error {
    if (self = [self init]) {
        postDirectory = directory;
        
        _path = [directory URLByAppendingPathComponent:METADATA_FILENAME];
        
        [self readWithError:error];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        [self extractDataFromDictionary:dictionary];
    }
    
    return self;
}

- (void)extractDataFromDictionary:(NSDictionary *)dictionary {
    draft = [[dictionary objectForKey:@"draft"] boolValue];
    
    // Must convert back into NSDate from string
    NSDateFormatter *dateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd'T'hh:mm:ssZ"];
    NSString *dateString = [dictionary objectForKey:@"publishedDate"];
    
	publishedDate = [dateFormatter dateFromString:dateString];    
}

- (BOOL)readWithError:(NSError **)error {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_path path]] == NO) {
        return NO;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:_path];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    if (data) {
        [self extractDataFromDictionary:dictionary];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)writeWithError:(NSError **)error {
    if (!postDirectory) {
        return NO;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:0 error:error];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [string writeToURL:_path atomically:YES encoding:NSUTF8StringEncoding error:error];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:[NSNumber numberWithBool:draft] forKey:@"draft"];
    
    // Must format published date into string for JSON
    NSDateFormatter *dateFormatter = [NSDateFormatter tb_cachedDateFormatterFromString:@"yyyy-MM-dd'T'hh:mm:ssZ"];
	NSString *dateString = [dateFormatter stringFromDate:publishedDate];
    
    [dictionary setValue:dateString forKey:@"publishedDate"];
    
    return dictionary;
}

@end
