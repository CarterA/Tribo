//
//  TBSiteDocument.h
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

typedef void(^TBSiteDocumentPreviewCallback)(NSURL *localURL, NSError *error);

@class TBSite, TBHTTPServer;

@interface TBSiteDocument : NSDocument
@property (nonatomic, strong) TBSite *site;
@property (nonatomic, strong) TBHTTPServer *server;
@property (readonly) BOOL previewIsRunning;
- (void)startPreview:(TBSiteDocumentPreviewCallback)callback;
- (void)stopPreview;
@end
