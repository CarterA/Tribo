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

- (IBAction)showAddPostSheet:(id)sender;

- (IBAction)showActionMenu:(id)sender;
- (IBAction)preview:(id)sender;
- (IBAction)publish:(id)sender;
- (IBAction)showSettingsSheet:(id)sender;

@end
