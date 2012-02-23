//
//  TBTemplatesViewController.h
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TBViewController.h"

@interface TBTemplatesViewController : TBViewController
@property (nonatomic, weak) IBOutlet NSArrayController *assets;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

- (void)doubleClickRow:(NSTableView *)outlineView;
@end
