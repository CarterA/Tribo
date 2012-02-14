//
//  TBSiteDocument+Scripting.h
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSiteDocument.h"

@interface TBSiteDocument (Scripting)
- (void)startPreviewFromScript:(NSScriptCommand *)command;
- (void)stopPreviewFromScript:(NSScriptCommand *)command;
@end