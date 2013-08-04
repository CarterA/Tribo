//
//  TBSourceViewControllerViewController.h
//  Tribo
//
//  Created by Samuel Goodwin on 2/22/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TBViewController.h"

@interface TBSourceViewController : TBViewController
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) IBOutlet NSTreeController *assetTree;
@end
