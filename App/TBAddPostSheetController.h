//
//  TBAddPostSheetController.h
//  Tribo
//
//  Created by Carter Allen on 10/7/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

typedef void(^TBAddPostSheetControllerCompletionHandler)(NSString *title, NSString *slug);

@interface TBAddPostSheetController : NSWindowController
- (void)runModalForWindow:(NSWindow *)window completionBlock:(TBAddPostSheetControllerCompletionHandler)completionHandler;
@end