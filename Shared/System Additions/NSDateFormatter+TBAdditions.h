//
//  NSDateFormatter+TBAdditions.h
//  Tribo
//
//  Created by Carter Allen on 6/15/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (TBAdditions)
+ (instancetype)tb_cachedDateFormatterFromString:(NSString *)format;
@end
