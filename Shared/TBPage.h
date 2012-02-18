//
//  TBPage.h
//  Tribo
//
//  Created by Carter Allen on 9/30/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class GRMustacheTemplate;
@class TBSite;

@interface TBPage : NSObject
+ (TBPage *)pageWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError**)error;
- (BOOL)parse:(NSError **)error;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, weak) TBSite *site;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) GRMustacheTemplate *template;
@property (nonatomic, strong) NSArray *stylesheets;
@end
