//
//  TBTableView.h
//  Tribo
//
//  Created by Carter Allen on 10/8/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@protocol TBTableViewDelegate;

@interface TBTableView : NSTableView
- (IBAction)deleteSelectedRows:(id)sender;
@end

@protocol TBTableViewDelegate <NSTableViewDelegate>
- (void)tableView:(NSTableView *)tableView shouldDeleteRows:(NSIndexSet *)rowIndexes;
@end