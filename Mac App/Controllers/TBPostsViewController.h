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

@interface TBPostsViewController : TBViewController <QLPreviewPanelDelegate, QLPreviewPanelDataSource, NSMenuDelegate>
@property (nonatomic, assign) IBOutlet NSTableView *postTableView;

@property (assign) IBOutlet NSMenuItem *draftMenuItem;

- (IBAction)editPost:(id)sender;
- (IBAction)draft:(id)sender;
- (IBAction)previewPost:(id)sender;
- (IBAction)revealPost:(id)sender;
@end
