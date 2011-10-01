//
//  TBPost.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPage.h"

@interface TBPost : TBPage
+ (TBPost *)postWithURL:(NSURL *)URL;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *slug;
@end