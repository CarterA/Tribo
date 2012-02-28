//
//  TBPublisher.m
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPublisher.h"

@implementation TBPublisher
@synthesize site = _site;
@synthesize protocol = _protocol;
@synthesize progressHandler = _progressHandler;
@synthesize completionHandler = _completionHandler;
@synthesize errorHandler = _errorHandler;

- (id)initWithSite:(TBSite *)site {
	self = [super init];
	if (self) {
		self.site = site;
	}
	return self;
}

- (void)publish {
	
}

@end
