//
//  NSResponder+TBAdditions.h
//  Tribo
//
//  Created by Carter Allen on 8/11/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import <Cocoa/Cocoa.h>

@interface NSResponder (TBAdditions)
- (void)tb_presentErrorOnMainQueue:(NSError *)error;
@end
