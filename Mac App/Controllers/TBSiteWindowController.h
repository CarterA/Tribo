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

- (IBAction)switchToPosts:(id)sender;
- (IBAction)switchToTemplates:(id)sender;
- (IBAction)switchToSources:(id)sender;

- (IBAction)showSettingsSheet:(id)sender;

@end
