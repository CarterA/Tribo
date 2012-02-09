//
//  TBSite+Scripting.h
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSite.h"

@class TBPost;

@interface TBSite (Scripting)
- (NSScriptObjectSpecifier *)objectSpecifierForPost:(TBPost *)post;
@end