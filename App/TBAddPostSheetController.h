//
//  TBAddPostSheetController.h
//  Tribo
//
//  Created by Carter Allen on 10/7/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

typedef void(^TBAddPostSheetControllerCompletionHandler)(NSString *title, NSString *slug);

@interface TBAddPostSheetController : NSWindowController
- (void)runModalForWindow:(NSWindow *)window completionBlock:(TBAddPostSheetControllerCompletionHandler)completionHandler;
@end