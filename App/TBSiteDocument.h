//
//  TBSiteDocument.h
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

@class TBSite;

@interface TBSiteDocument : NSDocument
@property (nonatomic, strong) TBSite *site;
@property (nonatomic, assign) IBOutlet NSTableView *postTableView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) IBOutlet NSButton *previewButton;
- (IBAction)preview:(id)sender;
- (IBAction)editPost:(id)sender;
- (IBAction)previewPost:(id)sender;
@end