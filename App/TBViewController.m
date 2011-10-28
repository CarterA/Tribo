//
//  TBViewController.m
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBViewController.h"

@implementation TBViewController

- (id)init {
	NSString *nibName = [self defaultNibName];
	self = [super initWithNibName:nibName bundle:[NSBundle mainBundle]];
	return self;
}

- (NSString *)defaultNibName {
	return [self className];
}

- (void)viewDidLoad {}

- (void)loadView {
	[super loadView];
	[self viewDidLoad];
}

@end