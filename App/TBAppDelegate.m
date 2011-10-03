//
//  TBAppDelegate.m
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBAppDelegate.h"
#import "TBDocumentController.h"

@implementation TBAppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[TBDocumentController sharedDocumentController];
}
@end