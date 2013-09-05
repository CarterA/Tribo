//
//  TSPostTableCellView.h
//  Tribo
//
//  Created by Tanner Smith on 9/4/13.
//  Copyright (c) 2013 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TSPostTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *title;
@property (assign) IBOutlet NSTextField *draft;
@property (assign) IBOutlet NSTextField *date;
@property (assign) IBOutlet NSTextField *postExcerpt;

@end
