//
//  TBSiteWindowController.h
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class TBViewController, TBAddPostSheetController;

@interface TBSiteWindowController : NSWindowController <NSWindowDelegate>
@property (nonatomic, strong) NSArray *viewControllers;
@property (readonly) TBViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedViewControllerIndex;
@end