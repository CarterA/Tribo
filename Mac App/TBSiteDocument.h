//
//  TBSiteDocument.h
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

typedef void(^TBSiteDocumentPreviewCallback)(NSError *error);

@class TBSite, HTTPServer;

@interface TBSiteDocument : NSDocument
@property (nonatomic, strong) TBSite *site;
@property (nonatomic, strong) HTTPServer *server;
- (void)startPreview:(TBSiteDocumentPreviewCallback)callback;
- (void)stopPreview;
@end
