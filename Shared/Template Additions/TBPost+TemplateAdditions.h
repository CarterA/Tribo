//
//  TBPost+TemplateAdditions.h
//  Tribo
//
//  Created by Carter Allen on 5/13/13.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

//
//  Template additions contain properties designed to be accessed by templates.
//  No configuration "hooks" are provided, so all properties should be generated
//  lazily, caching anything expensive like date formatters.
//

#import "TBPost.h"

@interface TBPost (TemplateAdditions)
@property (readonly) NSString *dateString;
@property (readonly) NSString *XMLDate;
@property (readonly) NSString *summary;
@property (readonly) NSString *relativeURL;
@end
