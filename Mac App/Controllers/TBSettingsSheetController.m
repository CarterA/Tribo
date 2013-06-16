//
//  TBSettingsSheetController.m
//  Tribo
//
//  Created by Carter Allen on 2/27/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSettingsSheetController.h"
#import "TBSite.h"
#import <Security/Security.h>

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
@property (nonatomic, assign) IBOutlet NSTextField *remotePathField;

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)uploadViaPopUpDidChange:(id)sender;

- (void)loadFormValues;
- (void)updatePlaceholders;
- (NSDictionary *)dictionaryOfFormValues;
- (NSString *)passwordFromKeychain;
- (void)setStoredPassword:(NSString *)newPassword;
- (void)addNewKeychainItemForPassword:(NSString *)newPassword;

@end

@implementation TBSettingsSheetController

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
	
	self.siteNameField.stringValue = metadata[TBSiteNameMetadataKey] ?: @"";
	self.authorField.stringValue = metadata[TBSiteAuthorMetadataKey] ?: @"";
	self.baseURLField.stringValue = metadata[TBSiteBaseURLMetadataKey] ?: @"";
	NSNumber *numberOfRecentPosts = metadata[TBSiteNumberOfRecentPostsMetadataKey] ?: @5;
	self.numberOfRecentPostsField.objectValue = numberOfRecentPosts;
	self.recentPostsStepper.objectValue = numberOfRecentPosts;
	
	NSString *protocol = metadata[TBSiteProtocolKey];
	NSString *protocolTitle = @"SFTP";
	if ([protocol isEqualToString:TBSiteProtocolFTP])
		protocolTitle = @"FTP";
	else if ([protocol isEqualToString:TBSiteProtocolSFTP])
		protocolTitle = @"SFTP";
	[self.uploadViaPopUp selectItemWithTitle:protocolTitle];
	self.serverField.stringValue = metadata[TBSiteServerKey] ?: @"";
	self.portField.objectValue = metadata[TBSitePortKey] ?: @"";
	self.userNameField.stringValue = metadata[TBSiteUserNameKey] ?: @"";
	self.passwordField.stringValue = [self passwordFromKeychain] ?: @"";
	self.remotePathField.stringValue = metadata[TBSiteRemotePathKey] ?: @"";
	
	self.passwordField.stringValue = [self passwordFromKeychain] ?: @"";
	
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
	[self.portField.cell setPlaceholderString:[NSString stringWithFormat:@"%ld", port]];
}

- (void)controlTextDidChange:(NSNotification *)notification {
	[self updatePlaceholders];
}

- (NSDictionary *)dictionaryOfFormValues {
	
	NSNumber *numberOfRecentPosts = @([self.numberOfRecentPostsField.stringValue integerValue]);
	NSString *protocol = @"";
	if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"FTP"])
		protocol = TBSiteProtocolFTP;
	else if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"SFTP"])
		protocol = TBSiteProtocolSFTP;
	NSDictionary *values = @{TBSiteNameMetadataKey: self.siteNameField.stringValue,
							TBSiteAuthorMetadataKey: self.authorField.stringValue,
							TBSiteBaseURLMetadataKey: self.baseURLField.stringValue,
							TBSiteNumberOfRecentPostsMetadataKey: numberOfRecentPosts,
							TBSiteProtocolKey: protocol,
							TBSiteServerKey: self.serverField.stringValue,
							TBSitePortKey: self.portField.stringValue,
							TBSiteUserNameKey: self.userNameField.stringValue,
							TBSiteRemotePathKey: self.remotePathField.stringValue};
	
	return values;
	
}

- (NSString *)passwordFromKeychain {
	
	char *passwordBuffer = NULL;
	UInt32 passwordLength = 0;
	NSString *serverName = self.serverField.stringValue;
	NSString *accountName = self.userNameField.stringValue;
	if (!serverName || !accountName) return nil;
	UInt16 port = (UInt16)[self.portField integerValue];
	SecProtocolType protocol = 0;
	if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"FTP"])
		protocol = kSecProtocolTypeFTP;
	else if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"SFTP"])
		protocol = kSecProtocolTypeSSH;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, "", port, protocol, kSecAuthenticationTypeDefault, &passwordLength, (void **)&passwordBuffer, NULL);
	if (returnStatus != noErr)
		return nil;
	NSString *password = [[NSString alloc] initWithBytes:passwordBuffer length:passwordLength encoding: NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordBuffer);
	return password;
	
}

- (void)setStoredPassword:(NSString *)newPassword {
	
	NSString *serverName = self.serverField.stringValue;
	NSString *accountName = self.userNameField.stringValue;
	UInt16 port = (UInt16)[self.portField integerValue];
	SecProtocolType protocol = 0;
	if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"FTP"])
		protocol = kSecProtocolTypeFTP;
	else if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"SFTP"])
		protocol = kSecProtocolTypeSSH;
	SecKeychainItemRef item;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, NULL, port, protocol, kSecAuthenticationTypeDefault, NULL, NULL, &item);
	
	if (returnStatus != noErr) {
		[self addNewKeychainItemForPassword:newPassword];
		return;
	}
	if (!item)
		return;
	
	if (!newPassword) newPassword = @"";
	SecKeychainItemModifyAttributesAndData(item, NULL, (UInt32)newPassword.length, [newPassword UTF8String]);
	
}

- (void)addNewKeychainItemForPassword:(NSString *)newPassword {
	
	NSString *serverName = self.serverField.stringValue;
	NSString *accountName = self.userNameField.stringValue;
	UInt16 port = (UInt16)[self.portField integerValue];
	SecProtocolType protocol = 0;
	if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"FTP"])
		protocol = kSecProtocolTypeFTP;
	else if ([self.uploadViaPopUp.titleOfSelectedItem isEqualToString:@"SFTP"])
		protocol = kSecProtocolTypeSSH;
	if (!newPassword) newPassword = @"";
	SecKeychainAddInternetPassword(NULL, (UInt32)serverName.length, [serverName UTF8String], 0, NULL, (UInt32)accountName.length, [accountName UTF8String], 0, NULL, port, protocol, kSecAuthenticationTypeDefault, (UInt32)newPassword.length, [newPassword UTF8String], NULL);
	
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
	self.site.metadata = [self dictionaryOfFormValues];
	[self setStoredPassword:self.passwordField.stringValue];
}

@end
