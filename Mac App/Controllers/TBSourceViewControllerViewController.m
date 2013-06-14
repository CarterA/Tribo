//
//  TBSourceViewControllerViewController.m
//  Tribo
//
//  Created by Samuel Goodwin on 2/22/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSourceViewControllerViewController.h"
#import "TBAsset.h"

@implementation TBSourceViewControllerViewController
@synthesize outlineView = _outlineView;
@synthesize assetTree = _assetTree;

- (NSString *)defaultNibName {
	return @"TBSourceViewControllerView";
}

- (NSString *)title {
	return @"Sources";
}

- (void)awakeFromNib {
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(doubleClickRow:)];
}

- (void)doubleClickRow:(NSOutlineView *)outlineView {
    NSArray *assets = [self.assetTree selectedObjects];
    NSArray *assetURLS = [assets valueForKey:@"fileURL"];
    [assetURLS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *singleFileArray = @[obj];
        BOOL fileOpened = [[NSWorkspace sharedWorkspace] openURLs:singleFileArray withAppBundleIdentifier:nil options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        if(!fileOpened){
            [[NSWorkspace sharedWorkspace] openURLs:singleFileArray withAppBundleIdentifier:@"com.apple.TextEdit" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        }
    }];
}

@end
