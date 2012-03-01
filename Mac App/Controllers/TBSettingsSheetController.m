//
//  TBSettingsSheetController.m
//  Tribo
//
//  Created by Carter Allen on 2/27/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSettingsSheetController.h"
#import "TBSite.h"

@interface TBSettingsSheetController () <NSTextFieldDelegate>

@property (nonatomic, assign) IBOutlet NSTextField *siteNameField;
@property (nonatomic, assign) IBOutlet NSTextField *authorField;
@property (nonatomic, assign) IBOutlet NSTextField *baseURLField;
@property (nonatomic, assign) IBOutlet NSTextField *numberOfRecentPostsField;
@property (nonatomic, assign) IBOutlet NSStepper *recentPostsStepper;

@property (nonatomic, assign) IBOutlet NSPopUpButton *uploadViaPopUp;
@property (nonatomic, assign) IBOutlet NSTextField *serverField;
@property (nonatomic, assign) IBOutlet NSTextField *portField;
@property (nonatomic, assign) IBOutlet NSTextField *userNameField;
@property (nonatomic, assign) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, assign) IBOutlet NSButton *rememberInKeychainCheckbox;
@property (nonatomic, assign) IBOutlet NSTextField *remotePathField;

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)uploadViaPopUpDidChange:(id)sender;

- (void)loadFormValues;
- (void)updatePlaceholders;

@end

@implementation TBSettingsSheetController

@synthesize site = _site;

@synthesize siteNameField = _siteNameField;
@synthesize authorField = _authorField;
@synthesize baseURLField = _baseURLField;
@synthesize numberOfRecentPostsField = _numberOfRecentPostsField;
@synthesize recentPostsStepper = _recentPostsStepper;

@synthesize uploadViaPopUp = _uploadViaPopUp;
@synthesize serverField = _serverField;
@synthesize portField = _portField;
@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize rememberInKeychainCheckbox = _rememberInKeychainCheckbox;
@synthesize remotePathField = _remotePathField;

- (id)init {
    self = [super initWithWindowNibName:@"TBSettingsSheet"];
    return self;
}

- (void)runModalForWindow:(NSWindow *)window site:(TBSite *)site {
	[self loadWindow];
	self.site = site;
	[self loadFormValues];
	[self updatePlaceholders];
	[NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)uploadViaPopUpDidChange:(id)sender {
	[self updatePlaceholders];
}

- (void)loadFormValues {
	NSDictionary *metadata = self.site.metadata;
	self.siteNameField.stringValue = [metadata objectForKey:TBSiteNameMetadataKey] ?: @"";
	self.authorField.stringValue = [metadata objectForKey:TBSiteAuthorMetadataKey] ?: @"";
	self.baseURLField.stringValue = [metadata objectForKey:TBSiteBaseURLMetadataKey] ?: @"";
	NSNumber *numberOfRecentPosts = [metadata objectForKey:TBSiteNumberOfRecentPostsMetadataKey] ?: [NSNumber numberWithInteger:5];
	self.numberOfRecentPostsField.objectValue = numberOfRecentPosts;
	self.recentPostsStepper.objectValue = numberOfRecentPosts;
	
}

- (void)updatePlaceholders {
	[self.userNameField.cell setPlaceholderString:NSUserName()];
	NSInteger port = 0;
	if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"FTP"]) {
		port = 21;
		[self.passwordField.cell setPlaceholderString:@""];
	}
	else if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"SFTP"]) {
		port = 22;
		[self.passwordField.cell setPlaceholderString:@"Key-based authentication"];
	}
	[self.portField.cell setPlaceholderString:[NSString stringWithFormat:@"%d", port]];
	if (self.passwordField.stringValue.length > 0)
		self.rememberInKeychainCheckbox.enabled = YES;
	else
		self.rememberInKeychainCheckbox.enabled = NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
	[self updatePlaceholders];
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
