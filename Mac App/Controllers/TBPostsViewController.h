//
//  TBPostsViewController.h
//  Tribo
//
//  Created by Carter Allen on 10/24/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBViewController.h"
#import <Quartz/Quartz.h>

@class TBSiteDocument, TBAddPostSheetController;

@interface TBPostsViewController : TBViewController <QLPreviewPanelDelegate, QLPreviewPanelDataSource>
@property (nonatomic, assign) IBOutlet NSTableView *postTableView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) IBOutlet NSButton *previewButton;
@property (nonatomic, assign) IBOutlet NSTextField *postCountLabel;
@property (nonatomic, strong) TBAddPostSheetController *addPostSheetController;
- (IBAction)preview:(id)sender;
- (IBAction)editPost:(id)sender;
- (IBAction)previewPost:(id)sender;
- (IBAction)revealPost:(id)sender;
- (IBAction)showAddPostSheet:(id)sender;
@end
