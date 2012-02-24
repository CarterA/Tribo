//
//  TBSite.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class TBAsset;

@interface TBSite : NSObject

+ (TBSite *)siteWithRoot:(NSURL *)root;

- (BOOL)process:(NSError **)error;
- (BOOL)parsePosts:(NSError **)error;
- (NSURL *)addPostWithTitle:(NSString *)title slug:(NSString *)slug error:(NSError **)error;

@property (nonatomic, strong) NSURL *root;
@property (nonatomic, strong) NSURL *destination;
@property (nonatomic, strong) NSURL *sourceDirectory;
@property (nonatomic, strong) NSURL *postsDirectory;
@property (nonatomic, strong) NSURL *templatesDirectory;

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSSet *templateAssets;
@property (nonatomic, strong) NSSet *sourceAssets;
@end
