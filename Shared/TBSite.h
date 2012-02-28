//
//  TBSite.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class TBAsset;

@protocol TBSiteDelegate;

static NSString * const TBSiteNameMetadataKey = @"TBSiteName";
static NSString * const TBSiteAuthorMetadataKey = @"TBSiteAuthor";
static NSString * const TBSiteBaseURLMetadataKey = @"TBSiteBaseURL";
static NSString * const TBSiteNumberOfRecentPostsMetadataKey = @"TBSiteNumberOfRecentPosts";

@interface TBSite : NSObject

+ (TBSite *)siteWithRoot:(NSURL *)root;

- (BOOL)process:(NSError **)error;
- (BOOL)parsePosts:(NSError **)error;
- (NSURL *)addPostWithTitle:(NSString *)title slug:(NSString *)slug error:(NSError **)error;

@property (nonatomic, weak) id <TBSiteDelegate> delegate;

@property (nonatomic, strong) NSURL *root;
@property (nonatomic, strong) NSURL *destination;
@property (nonatomic, strong) NSURL *sourceDirectory;
@property (nonatomic, strong) NSURL *postsDirectory;
@property (nonatomic, strong) NSURL *templatesDirectory;

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSSet *templateAssets;
@property (nonatomic, strong) NSSet *sourceAssets;

@property (nonatomic, strong) NSDictionary *metadata;

@end

@protocol TBSiteDelegate <NSObject>
@optional
- (void)metadataDidChangeForSite:(TBSite *)site;
@end
