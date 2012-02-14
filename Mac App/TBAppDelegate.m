//
//  TBAppDelegate.m
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBAppDelegate.h"
#import "TBDocumentController.h"

@implementation TBAppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[TBDocumentController sharedDocumentController];
}
@end