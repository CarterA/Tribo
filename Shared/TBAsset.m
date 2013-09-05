//
//  TBAsset.m
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBAsset.h"

@implementation TBAsset

+ (NSArray *)assetsFromDirectory:(NSURL*)URL error:(NSError **)error {
	
    NSMutableArray *assets = [NSMutableArray array];
    NSArray *properties = @[NSURLTypeIdentifierKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:URL includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    for (NSURL *assetURL in enumerator) {
		
		NSDictionary *resourceValues = [assetURL resourceValuesForKeys:properties error:error];
		if (!resourceValues) return nil;
        
        TBAsset *asset = [[self class] new];
		asset.URL = assetURL;
		asset.displayName = resourceValues[NSURLLocalizedNameKey];
		asset.type = resourceValues[NSURLTypeIdentifierKey];
		
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
			asset.children = [[self class] assetsFromDirectory:assetURL error:error];
			if (!asset.children) return nil;
		}
        
        [assets addObject:asset];
		
    }
	
	[assets sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]]];
	
    return assets;
	
}

- (BOOL)isLeaf {
    return ([self.children count] == 0);
}

@end
