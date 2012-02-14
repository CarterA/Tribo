//
//  TBPost+Scripting.m
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPost+Scripting.h"
#import "TBSite+Scripting.h"

@implementation TBPost (Scripting)
- (NSScriptObjectSpecifier *)objectSpecifier {
	return [self.site objectSpecifierForPost:self];
}
- (NSTextStorage *)markdownContentForScripting {
	return [[NSTextStorage alloc] initWithString:self.markdownContent];
}
- (NSTextStorage *)HTMLContentForScripting {
	return [[NSTextStorage alloc] initWithString:self.content];
}
@end