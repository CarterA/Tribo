//
//  TBPost+Scripting.h
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPost.h"

@interface TBPost (Scripting)
- (NSScriptObjectSpecifier *)objectSpecifier;
- (NSTextStorage *)markdownContentForScripting;
- (NSTextStorage *)HTMLContentForScripting;
@end
