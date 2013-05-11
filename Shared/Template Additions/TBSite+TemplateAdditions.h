//
//  TBSite+TemplateAdditions.h
//  Tribo
//
//  Created by Carter Allen on 5/11/13.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

//
//  Template additions contain properties designed to be accessed by templates.
//  No configuration "hooks" are provided, so all properties should be generated
//  lazily, caching anything expensive like date formatters.
//  

#import "TBSite.h"

@class TBPost;

@interface TBSite (TemplateAdditions)
@property (nonatomic, readonly) TBPost *latestPost;
@property (nonatomic, readonly) NSArray *recentPosts;
@property (nonatomic, readonly) NSString *XMLDate;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *author;
@property (nonatomic, readonly) NSString *baseURL;
@end
