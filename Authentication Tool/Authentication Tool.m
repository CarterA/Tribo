//
//  main.m
//  Tribo Authentication Tool
//
//  Created by Carter Allen on 2/29/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

static NSString * const TBAuthenticationSSHServiceName = @"SSH";

NSString * fetchPassphraseForIdentityFromKeychain(NSString *identityPath);
NSString * promptForPassphraseForIdentity(NSString *identityPath);
void addPassphraseForIdentityToKeychain(NSString *identityPath, NSString *password);

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		
		NSArray *argumentsArray = [[NSProcessInfo processInfo] arguments];
		if ([argumentsArray count] >= 2) {
			NSRange yesOrNoRange = [[argumentsArray objectAtIndex:1] rangeOfString:[NSString stringWithFormat:@"(yes/no)"]];
			if (yesOrNoRange.location != NSNotFound){
				printf("YES");
				return 0;
			}
		}
		
		NSString *identityPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"TB_IDENTITY_PATH"];
		
		NSString *passphrase = fetchPassphraseForIdentityFromKeychain(identityPath);
		
		if (!passphrase)
			passphrase = promptForPassphraseForIdentity(identityPath);
		
		if (!passphrase)
			return 1;
		
		printf("%s", [passphrase UTF8String]);
		return 0;
		
	}
    return 1;
}

NSString * fetchPassphraseForIdentityFromKeychain(NSString *identityPath) {
	
	NSString *serviceName = TBAuthenticationSSHServiceName;
	
	UInt32 passwordLength = 0;
	char *password = nil;
	SecKeychainItemRef item = nil;
	
	OSStatus returnStatus = SecKeychainFindGenericPassword(NULL, (UInt32)serviceName.length, [serviceName UTF8String], (UInt32)identityPath.length, [identityPath UTF8String], &passwordLength, (void **)&password, &item);
	if (returnStatus != noErr)
		return nil;
	else if (!item) {
		SecKeychainItemFreeContent(NULL, password);
		return nil;
	}
	NSString *passwordString = [[NSString alloc] initWithBytes:password length:passwordLength encoding: NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, password);
	
	return passwordString;
	
}

NSString * promptForPassphraseForIdentity(NSString *identityPath) {
	
	CFDictionaryRef notificationOptions = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Tribo needs the passphrase for %@, an SSH private key.", identityPath], kCFUserNotificationAlertHeaderKey, @"", kCFUserNotificationTextFieldTitlesKey, @"Add to Keychain", kCFUserNotificationCheckBoxTitlesKey, @"Cancel", kCFUserNotificationAlternateButtonTitleKey, nil];
	CFUserNotificationRef notification = CFUserNotificationCreate(kCFAllocatorDefault, 0, kCFUserNotificationPlainAlertLevel|CFUserNotificationSecureTextField(0), NULL, notificationOptions);
	
	CFOptionFlags responseFlags = (CFOptionFlags)0;
	CFUserNotificationReceiveResponse(notification, 0, &responseFlags);
	
	int button = responseFlags & 0x3;
	if (button == kCFUserNotificationAlternateResponse) {
		CFRelease(notification);
		return nil;
	}
	
	NSString *passphrase = [(__bridge NSString *)CFUserNotificationGetResponseValue(notification, kCFUserNotificationTextFieldValuesKey, 0) copy];
	CFRelease(notification);
	
	if (responseFlags & CFUserNotificationCheckBoxChecked(0)) {
		addPassphraseForIdentityToKeychain(identityPath, passphrase);
	}
	
	return passphrase;
	
}

void addPassphraseForIdentityToKeychain(NSString *identityPath, NSString *passphrase) {
	
	NSString *serviceName = TBAuthenticationSSHServiceName;
	SecKeychainAddGenericPassword(NULL, (UInt32)serviceName.length, [serviceName UTF8String], (UInt32)identityPath.length, [identityPath UTF8String], (UInt32)passphrase.length, [passphrase UTF8String], NULL);
	
}
