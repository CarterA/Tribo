//
//  TSPostTableCellView.m
//  Tribo
//
//  Created by Tanner Smith on 9/4/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import "TSPostTableCellView.h"

@implementation TSPostTableCellView

@synthesize title, date, draft, postExcerpt;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    switch (backgroundStyle) {
        case NSBackgroundStyleDark:
            [title setTextColor:[NSColor whiteColor]];
            [date setTextColor:[NSColor whiteColor]];
            [draft setTextColor:[NSColor whiteColor]];
            [postExcerpt setTextColor:[NSColor whiteColor]];
            break;
        default:
            [title setTextColor:[NSColor blackColor]];
            [date setTextColor:[NSColor blueColor]];
            [draft setTextColor:[NSColor redColor]];
            [postExcerpt setTextColor:[NSColor grayColor]];
            break;
    }
}

@end
