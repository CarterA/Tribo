//
//  TSPostMetadata.h
//  Tribo
//
//  Created by Tanner Smith on 8/27/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import <Foundation/Foundation.h>

/*!
 @class TSPostMetdata
 @discussion Post metadata represents any extra data, i.e. metadata, about
 a post (data other than the post itself). Metadata is written to the disk
 in a standized format.
 */

@interface TSPostMetadata : NSObject

#define METADATA_FILENAME @"metadata.json"

/*!
    @property postDirectory
        The directory the post resides in. Contains the post markdown file (known
        as slug.md) and metadata file.
 */
@property (retain, strong) NSURL *postDirectory;

/*!
    @property path
        The complete path to the metadata file.
 */
@property (retain, strong) NSURL *path;

/*!
    @property draft
        The state of the post, i.e. is it a draft (unfinished).
 */
@property (assign) BOOL draft;

/*!
    @property publishedDate
        The date when the post was published and was no longer a draft.
 */
@property (retain, strong) NSDate *publishedDate;

/*!
    Create an empty metadata object.
 */
- (instancetype)init;

/*!
    Create an metadata object from a post directory.
    @param error
        If the return value is nil, then this argument will contain an NSError
        object describing what went wrong.
    @return
        A TSPostMetadata object, or nil if an error was encountered.
 */
- (instancetype)initWithPostDirectory:(NSURL *)directory withError:(NSError **)error;

/*!
    Extract the metadata data from the given directory.

    Populates the member variables with this data.
 
    @param dictionary
        Dictionary containing data.
 */
- (void)extractDataFromDictionary:(NSDictionary *)dictionary;

/*!
    Read the metadata file and store the data in the member variables.
    @param error
        If the return value is nil, then this argument will contain an NSError
        object describing what went wrong.
    @return
        YES if an error was encountered.
 */
- (BOOL)readWithError:(NSError **)error;

/*!
    Write the metadata file from data in the member variables.
    @param error
        If the return value is nil, then this argument will contain an NSError
        object describing what went wrong.
    @return
        YES if an error was encountered.
 */
- (BOOL)writeWithError:(NSError **)error;

@end
