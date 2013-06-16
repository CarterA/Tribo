//
//  TBTemplateAsset.m
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBAsset.h"

@implementation TBAsset

+ (NSSet *)assetsFromDirectoryURL:(NSURL*)folderURL {    
    NSMutableSet *subAssets = [NSMutableSet set];
    NSArray *properties = @[NSURLTypeIdentifierKey, NSURLNameKey, NSURLIsDirectoryKey];
    NSDirectoryEnumerator *subAssetsEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:folderURL includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        NSLog(@"Error!: %@", [error localizedDescription]);
        return NO;
    }];
    for (NSURL *assetURL in subAssetsEnumerator) {
        NSNumber *isADirectory;
        [assetURL getResourceValue:&isADirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        NSString *fileName;
        [assetURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        NSString *fileType;
        [assetURL getResourceValue:&fileType forKey:NSURLTypeIdentifierKey error:NULL];
        
        TBAsset *asset = [[self alloc] init];
        [asset setFilename:[assetURL lastPathComponent]];
        [asset setFileURL:assetURL];
        [asset setFileType:fileType];
        if([isADirectory boolValue]) {
            [asset setTemplateAssets:[self assetsFromDirectoryURL:assetURL]];
        }
        
        [subAssets addObject:asset];
    }
    return subAssets;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@ children: %@>", [self class], [self filename], [self templateAssets]];
}

- (NSArray *)children {
    NSSortDescriptor *filenameSort = [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES];
    return [[self templateAssets] sortedArrayUsingDescriptors:@[filenameSort]];
}

- (BOOL)isLeaf {
    return ![[self fileType] isEqualToString:@"public.folder"];
}

@end
