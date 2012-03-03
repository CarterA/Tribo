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

extern NSString * const TBSiteNameMetadataKey;
extern NSString * const TBSiteAuthorMetadataKey;
extern NSString * const TBSiteBaseURLMetadataKey;
extern NSString * const TBSiteNumberOfRecentPostsMetadataKey;

extern NSString * const TBSiteProtocolKey;
extern NSString * const TBSiteProtocolFTP;
extern NSString * const TBSiteProtocolSFTP;
extern NSString * const TBSiteServerKey;
extern NSString * const TBSitePortKey; // Not a teleportation device
extern NSString * const TBSiteUserNameKey;
extern NSString * const TBSiteRemotePathKey;

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
