//
//  TBViewController.h
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class TBSiteDocument;
@interface TBViewController : NSViewController
@property (nonatomic, weak) TBSiteDocument *document;
- (NSString *)defaultNibName;
- (void)viewDidLoad;
@end
