//
//  TBSite.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

@interface TBSite : NSObject

- (void)process;

@property (nonatomic, strong) NSURL *root;
@property (nonatomic, strong) NSURL *destination;
@property (nonatomic, strong) NSURL *sourceDirectory;
@property (nonatomic, strong) NSURL *postsDirectory;
@property (nonatomic, strong) NSURL *templatesDirectory;

@end