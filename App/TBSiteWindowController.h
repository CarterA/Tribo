//
//  TBSiteWindowController.h
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

@class TBViewController, TBAddPostSheetController;

@interface TBSiteWindowController : NSWindowController <NSWindowDelegate>
@property (nonatomic, strong) NSArray *viewControllers;
@property (readonly) TBViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedViewControllerIndex;
@end