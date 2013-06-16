//
//  TBStatusViewController.m
//  Tribo
//
//  Created by Carter Allen on 3/13/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBStatusViewController.h"

@interface TBStatusViewController ()
- (IBAction)openLink:(id)sender;
- (IBAction)stop:(id)sender;
@end

@implementation TBStatusViewController

- (NSString *)defaultNibName {
	return @"TBStatusView";
}

- (IBAction)openLink:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:self.link];
}

- (IBAction)stop:(id)sender {
	if (self.stopHandler) self.stopHandler();
}

@end
