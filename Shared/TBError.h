//
//  TBError.h
//  Tribo
//
//  Created by Samuel Goodwin on 1/31/12.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

extern const struct TBError {
	NSError *(*missingPostsDirectory)(NSURL *postsDirectory);
	NSError *(*missingPostPartial)(NSURL *postPartial);
	NSError *(*missingPostDate)(NSURL *postURL);
	NSError *(*missingSourceDirectory)(NSURL *sourceDirectory);
	NSError *(*filterStandardError)(NSURL *filterURL, NSString *standardError);
	NSError *(*emptyPostFile)(NSURL *postURL);
	NSError *(*emptyPageFile)(NSURL *pageURL);
} TBError;
