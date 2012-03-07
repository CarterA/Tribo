//
//  TBPublishSheetController.h
//  Tribo
//
//  Created by Carter Allen on 2/29/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import <Cocoa/Cocoa.h>

@class TBSite;

@interface TBPublishSheetController : NSWindowController
@property (nonatomic, strong) TBSite *site;
- (void)runModalForWindow:(NSWindow *)window site:(TBSite *)site;
@end
