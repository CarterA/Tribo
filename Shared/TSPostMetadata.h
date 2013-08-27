//
//  TSPostMetadata.h
//  Tribo
//
//  Created by Tanner Smith on 8/27/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import <Foundation/Foundation.h>

@interface TSPostMetadata : NSObject

#define METADATA_FILENAME @"metadata.json"

@property (retain, strong) NSURL *postDirectory;
@property (retain, strong) NSURL *path;

@property (assign) BOOL draft;
@property (retain, strong) NSDate *publishedDate;

- (instancetype)init;
- (instancetype)initWithPostDirectory:(NSURL *)directory withError:(NSError **)error;

- (void)extractDataFromDictionary:(NSDictionary *)dictionary;

- (BOOL)readWithError:(NSError **)error;
- (BOOL)writeWithError:(NSError **)error;

@end
