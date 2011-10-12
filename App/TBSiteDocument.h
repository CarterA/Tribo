//
//  TBSiteDocument.h
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import <Quartz/Quartz.h>

@class TBSite, TBAddPostSheetController;

@interface TBSiteDocument : NSDocument <NSWindowDelegate, QLPreviewPanelDelegate, QLPreviewPanelDataSource>
@property (nonatomic, strong) TBSite *site;
@property (nonatomic, assign) IBOutlet NSTableView *postTableView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) IBOutlet NSButton *previewButton;
@property (nonatomic, assign) IBOutlet NSTextField *postCountLabel;
@property (nonatomic, strong) TBAddPostSheetController *addPostSheetController;
- (IBAction)preview:(id)sender;
- (IBAction)showAddPostSheet:(id)sender;
- (IBAction)editPost:(id)sender;
- (IBAction)previewPost:(id)sender;
- (IBAction)revealPost:(id)sender;
@end