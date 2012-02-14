//
//  TBTableView.m
//  Tribo
//
//  Created by Carter Allen on 10/8/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBTableView.h"
#import <Quartz/Quartz.h>

@implementation TBTableView
- (void)keyDown:(NSEvent *)event {
	NSString* key = [event charactersIgnoringModifiers];
	if([key isEqual:@" "]) {
		if ([QLPreviewPanel sharedPreviewPanel].isKeyWindow) {
			[[QLPreviewPanel sharedPreviewPanel] close];
		}
		else {
			[[QLPreviewPanel sharedPreviewPanel] updateController];
			[[QLPreviewPanel sharedPreviewPanel] reloadData];
			[QLPreviewPanel sharedPreviewPanel].currentPreviewItemIndex = self.selectedRow;
			[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
		}
	}
	else {
		[super keyDown:event];
	}
}
- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
	return YES;
}
- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
	panel.delegate = (id <QLPreviewPanelDelegate>)self.delegate;
	panel.dataSource = (id <QLPreviewPanelDataSource>)self.delegate;
}
- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
	return;
}
@end