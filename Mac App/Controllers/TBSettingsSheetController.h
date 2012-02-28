//
//  TBSettingsSheetController.h
//  Tribo
//
//  Created by Carter Allen on 2/27/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBSite;

@interface TBSettingsSheetController : NSWindowController
@property (nonatomic, strong) TBSite *site;
- (void)runModalForWindow:(NSWindow *)window site:(TBSite *)site;
@end
