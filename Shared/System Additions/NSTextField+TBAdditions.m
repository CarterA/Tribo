//
//  NSTextField+TBAdditions.m
//  Tribo
//
//  Created by Tanner Smith on 9/5/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import "NSTextField+TBAdditions.h"

@implementation NSTextField (TBAdditions)

- (void)tb_setPlaceholderTextColor:(NSColor *)aColor {
    NSString *placeholderString = [[self cell] placeholderString];
    
    if (!placeholderString) {
        placeholderString = [[[self cell] placeholderAttributedString] string];
        
        if (!placeholderString) {
            return;
        }
    }

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:placeholderString attributes:@{aColor : NSForegroundColorAttributeName}];
    
    [[self cell] setPlaceholderAttributedString:attributedString];
}

@end
