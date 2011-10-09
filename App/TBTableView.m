//
//  TBTableView.m
//  Tribo
//
//  Created by Carter Allen on 10/8/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBTableView.h"
#import "TBSiteDocument.h"

@implementation TBTableView
- (void)keyDown:(NSEvent *)event {
	NSString* key = [event charactersIgnoringModifiers];
	if([key isEqual:@" "]) {
		[(TBSiteDocument *)self.delegate toggleQuickLookPopover];
	}
	else {
		[super keyDown:event];
	}
}
@end