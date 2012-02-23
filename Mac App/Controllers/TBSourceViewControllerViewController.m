//
//  TBSourceViewControllerViewController.m
//  Tribo
//
//  Created by Samuel Goodwin on 2/22/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSourceViewControllerViewController.h"
#import "TBAsset.h"

@interface TBSourceViewControllerViewController ()

@end

@implementation TBSourceViewControllerViewController

- (NSString *)defaultNibName {
	return @"TBSourceViewControllerView";
}

- (NSString *)title {
	return @"Sources";
}

- (void)awakeFromNib{
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(doubleClickRow:)];
}

- (void)doubleClickRow:(NSOutlineView *)outlineView{
    TBAsset *asset = [[self.assetTree selectedObjects] lastObject];
    BOOL fileOpened = [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:asset.fileURL] withAppBundleIdentifier:nil options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    if(!fileOpened){
        [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:asset.fileURL] withAppBundleIdentifier:@"com.apple.TextEdit" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    }
}

@end
