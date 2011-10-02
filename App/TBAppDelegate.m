//
//  TBAppDelegate.m
//  Tribo
//
//  Created by Carter Allen on 10/1/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBAppDelegate.h"
#import "TBSite.h"

@implementation TBAppDelegate
@synthesize window=_window;
@synthesize site=_site;
- (void)awakeFromNib {
	self.site = [TBSite new];
	self.site.root = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"root"] isDirectory:YES];
	self.site.destination = [self.site.root URLByAppendingPathComponent:@"Output" isDirectory:YES];
	self.site.sourceDirectory = [self.site.root URLByAppendingPathComponent:@"Source" isDirectory:YES];
	self.site.postsDirectory = [self.site.root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
	self.site.templatesDirectory = [self.site.root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
	[self.site process];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}
@end