//
//  TBTemplatesViewController.m
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBTemplatesViewController.h"
#import "TBSiteDocument.h"
#import "TBAsset.h"
#import "TBSite.h"

@interface TBTemplatesViewController ()

@end

@implementation TBTemplatesViewController

- (NSString *)defaultNibName {
	return @"TBTemplatesView";
}

- (NSString *)title {
	return @"Templates";
}

- (void)awakeFromNib{
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(doubleClickRow:)];
}

- (NSArray *)templates{
    NSArray *nameSort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES]];
    return [self.document.site.templateAssets sortedArrayUsingDescriptors:nameSort];
}

- (void)doubleClickRow:(NSOutlineView *)outlineView{
    NSArray *assets = [self.assets selectedObjects];
    NSArray *assetURLS = [assets valueForKey:@"fileURL"];
    [assetURLS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *singleFileArray = [NSArray arrayWithObject:obj];
        BOOL fileOpened = [[NSWorkspace sharedWorkspace] openURLs:singleFileArray withAppBundleIdentifier:nil options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        if(!fileOpened){
            [[NSWorkspace sharedWorkspace] openURLs:singleFileArray withAppBundleIdentifier:@"com.apple.TextEdit" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        }
    }];
}

@end
