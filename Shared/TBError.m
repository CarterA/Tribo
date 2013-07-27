//
//  TBError.h
//  Tribo
//
//  Created by Carter Allen on 7/27/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBError.h"

NSString * const TBErrorDomain = @"com.opt-6.Tribo.ErrorDomain";
NSString * const TBErrorStringsTable = @"TBError.strings";

enum {
	TBErrorMissingPostsDirectory = 42,
	TBErrorMissingPostPartial,
	TBErrorMissingSourceDirectory,
	TBErrorFilterStandardError,
	TBErrorEmptyPostFile,
	TBErrorEmptyPageFile
};

static NSError *missingPostsDirectory(NSURL *postsDirectory) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"MISSING_POSTS_DIRECTORY", TBErrorStringsTable, nil), postsDirectory.path];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorMissingPostsDirectory userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *missingPostPartial(NSURL *partialURL) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"MISSING_POST_PARTIAL", TBErrorStringsTable, nil), partialURL.path];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorMissingPostPartial userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *missingSourceDirectory(NSURL *sourceDirectory) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"MISSING_SOURCE_DIRECTORY", TBErrorStringsTable, nil), sourceDirectory.path];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorMissingSourceDirectory userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *filterStandardError(NSURL *filterURL, NSString *standardError) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"FILTER_STANDARD_ERROR", TBErrorStringsTable, nil), filterURL.path, standardError];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorFilterStandardError userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *emptyPostFile(NSURL *postURL) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"EMPTY_POST_FILE", TBErrorStringsTable, nil), postURL.path];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorEmptyPostFile userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *emptyPageFile(NSURL *pageURL) {
	NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTable(@"EMPTY_PAGE_FILE", TBErrorStringsTable, nil), pageURL.path];
	return [NSError errorWithDomain:TBErrorDomain code:TBErrorEmptyPageFile userInfo:@{NSLocalizedDescriptionKey: description}];
}

const struct TBError TBError = {
	.missingPostsDirectory = missingPostsDirectory,
	.missingPostPartial = missingPostPartial,
	.missingSourceDirectory = missingSourceDirectory,
	.filterStandardError = filterStandardError,
	.emptyPostFile = emptyPostFile,
	.emptyPageFile = emptyPageFile
};
