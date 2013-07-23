//
//  TBPost.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPage.h"

@interface TBPost : TBPage
+ (TBPost *)postWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError **)error;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *markdownContent;
@end
