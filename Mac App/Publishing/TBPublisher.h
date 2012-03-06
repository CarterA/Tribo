//
//  TBPublisher.h
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSite;

typedef void(^TBPublisherProgressHandler)(NSInteger progress, NSInteger total);
typedef void(^TBPublisherCompletionHandler)();
typedef void(^TBPublisherErrorHandler)(NSError *error);

@interface TBPublisher : NSObject

@property (nonatomic, strong) TBSite *site;

@property (nonatomic, copy) TBPublisherProgressHandler progressHandler;
@property (nonatomic, copy) TBPublisherCompletionHandler completionHandler;
@property (nonatomic, copy) TBPublisherErrorHandler errorHandler;

- (void)publish;

@end
