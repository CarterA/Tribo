//
//  TBSiteDocument.h
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

@class TBSite, HTTPServer;

@interface TBSiteDocument : NSDocument
@property (nonatomic, strong) TBSite *site;
@property (nonatomic, strong) HTTPServer *server;
- (void)startPreview;
- (void)stopPreview;
@end