//
//  TBPublisher.m
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPublisher.h"
#import "TBSite.h"

#import "TBFTPPublisher.h"
#import "TBSFTPPublisher.h"

@interface TBPlaceholderPublisher : TBPublisher
@end

@implementation TBPublisher

+ (instancetype)publisherWithSite:(TBSite *)site {
	NSString *protocol = (site.metadata)[TBSiteProtocolKey];
	if ([protocol isEqualToString:TBSiteProtocolFTP])
		return [[TBFTPPublisher alloc] initWithSite:site];
	else if ([protocol isEqualToString:TBSiteProtocolSFTP])
		return [[TBSFTPPublisher alloc] initWithSite:site];
	[[NSException exceptionWithName:@"TBPublisherUnrecognizedProtocolException" reason:@"The protocol key of the site's metadata dictionary did not contain a valid protocol." userInfo:nil] raise];
	return nil;
}

- (instancetype)initWithSite:(TBSite *)site {
	self = [super init];
	if (self) {
		self.site = site;
	}
	return self;
}

- (void)publish {}

@end
