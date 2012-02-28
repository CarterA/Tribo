//
//  TBSettingsSheetController.m
//  Tribo
//
//  Created by Carter Allen on 2/27/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSettingsSheetController.h"
#import "TBSite.h"

@interface TBSettingsSheetController ()
@property (nonatomic, assign) IBOutlet NSTextField *siteNameField;
@property (nonatomic, assign) IBOutlet NSTextField *authorField;
@property (nonatomic, assign) IBOutlet NSTextField *baseURLField;
@property (nonatomic, assign) IBOutlet NSTextField *numberOfRecentPostsField;
@property (nonatomic, assign) IBOutlet NSStepper *recentPostsStepper;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@end

@implementation TBSettingsSheetController
@synthesize site = _site;
@synthesize siteNameField = _siteNameField;
@synthesize authorField = _authorField;
@synthesize baseURLField = _baseURLField;
@synthesize numberOfRecentPostsField = _numberOfRecentPostsField;
@synthesize recentPostsStepper = _recentPostsStepper;

- (id)init {
    self = [super initWithWindowNibName:@"TBSettingsSheet"];
    return self;
}

- (void)runModalForWindow:(NSWindow *)window site:(TBSite *)site {
	[self loadWindow];
	self.site = site;
	NSDictionary *metadata = site.metadata;
	self.siteNameField.stringValue = [metadata objectForKey:TBSiteNameMetadataKey] ?: @"";
	self.authorField.stringValue = [metadata objectForKey:TBSiteAuthorMetadataKey] ?: @"";
	self.baseURLField.stringValue = [metadata objectForKey:TBSiteBaseURLMetadataKey] ?: @"";
	NSNumber *numberOfRecentPosts = [metadata objectForKey:TBSiteNumberOfRecentPostsMetadataKey] ?: [NSNumber numberWithInteger:5];
	self.numberOfRecentPostsField.objectValue = numberOfRecentPosts;
	self.recentPostsStepper.objectValue = numberOfRecentPosts;
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)save:(id)sender {
	[NSApp endSheet:self.window returnCode:NSOKButton];
}

- (IBAction)cancel:(id)sender {
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self.window orderOut:self];
	if (returnCode != NSOKButton) return;
	NSNumber *numberOfRecentPosts = [NSNumber numberWithInteger:[self.numberOfRecentPostsField.stringValue integerValue]];
	NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:self.siteNameField.stringValue, TBSiteNameMetadataKey, self.authorField.stringValue, TBSiteAuthorMetadataKey, self.baseURLField.stringValue, TBSiteBaseURLMetadataKey, numberOfRecentPosts, TBSiteNumberOfRecentPostsMetadataKey, nil];
	self.site.metadata = metadata;
}

@end
