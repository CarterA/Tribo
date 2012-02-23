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
    TBAsset *asset = [[self.assets selectedObjects] lastObject];
    BOOL fileOpened = [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:asset.fileURL] withAppBundleIdentifier:nil options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    if(!fileOpened){
        [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:asset.fileURL] withAppBundleIdentifier:@"com.apple.TextEdit" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    }
}

@end
