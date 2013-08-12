//
//  NSResponder+TBAdditions.m
//  Tribo
//
//  Created by Carter Allen on 8/11/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "NSResponder+TBAdditions.h"
#import "TBMacros.h"

@implementation NSResponder (TBAdditions)

- (void)tb_presentErrorOnMainQueue:(NSError *)error {
	MAWeakSelfDeclare();
	dispatch_async(dispatch_get_main_queue(), ^{
		MAWeakSelfImport();
		[self presentError:error];
	});
}

@end
