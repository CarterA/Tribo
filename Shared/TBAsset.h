//
//  TBTemplateAsset.h
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBAsset : NSObject
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSSet *templateAssets;

+ (NSSet *)assetsFromDirectoryURL:(NSURL*)fileURL;

- (NSArray *)children;
- (BOOL)isLeaf;
@end
