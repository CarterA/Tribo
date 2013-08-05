//
//  TBStatusViewController.h
//  Tribo
//
//  Created by Carter Allen on 3/13/12.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBViewController.h"

typedef void(^TBStatusViewControllerStopHandler)();

@interface TBStatusViewController : TBViewController
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, copy) TBStatusViewControllerStopHandler stopHandler;
@end
