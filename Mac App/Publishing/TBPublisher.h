//
//  TBPublisher.h
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
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

+ (instancetype)publisherWithSite:(TBSite *)site;
- (instancetype)initWithSite:(TBSite *)site;
- (void)publish;

@end
