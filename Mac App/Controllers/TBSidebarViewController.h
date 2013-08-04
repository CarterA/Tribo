//
//  TBSidebarViewController.h
//  Tribo
//
//  Created by Carter Allen on 8/1/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBViewController.h"

@protocol TBSidebarViewControllerDelegate;

@interface TBSidebarViewController : TBViewController
@property (nonatomic, weak) id <TBSidebarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *selectedFile;
@end

@protocol TBSidebarViewControllerDelegate <NSObject>
- (void)sidebarViewDidSelectFile:(NSURL *)selectedFile;
@end
