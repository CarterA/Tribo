//
//  TBPage+LiveReload.m
//  Tribo
//
//  Created by Carter Allen on 2/25/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPage+LiveReload.h"

@implementation TBPage (LiveReload)

- (NSString *)livereload {
	return [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"LiveReload Snippet" withExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
}

@end
