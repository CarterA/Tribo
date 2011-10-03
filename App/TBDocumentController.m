//
//  TBDocumentController.m
//  Tribo
//
//  Created by Carter Allen on 10/3/11.
//  Copyright (c) 2011 Opt-6 Products, LLC. All rights reserved.
//

#import "TBDocumentController.h"

@implementation TBDocumentController
- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	return [super runModalOpenPanel:openPanel forTypes:types];
}
@end