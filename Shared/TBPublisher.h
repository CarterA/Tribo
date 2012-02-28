//
//  TBPublisher.h
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSite;

typedef enum {
	TBPublisherProtocolFTP,
	TBPublisherProtocolSFTP
} TBPublisherProtocol;

typedef void(^TBPublisherProgressHandler)(NSUInteger progress, NSUInteger total);
typedef void(^TBPublisherCompletionHandler)();
typedef void(^TBPublisherErrorHandler)(NSError *error);

@interface TBPublisher : NSObject

@property (nonatomic, strong) TBSite *site;
@property (nonatomic, assign) TBPublisherProtocol protocol;

@property (nonatomic, copy) TBPublisherProgressHandler progressHandler;
@property (nonatomic, copy) TBPublisherCompletionHandler completionHandler;
@property (nonatomic, copy) TBPublisherErrorHandler errorHandler;

- (void)publish;

@end
