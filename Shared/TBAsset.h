//
//  TBAsset.h
//  Tribo
//
//  Created by Samuel Goodwin on 2/20/12.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

/*!
	@class TBAsset
	@discussion An asset represents a file or folder inside a site's root 
	directory. A site object manages a tree of assets which mirrors the on-disk 
	structure of the site. Thus, assets are recursive in nature, and should be 
	thought of as a tree data structure. Currently, the asset tree is primarily 
	used for user interface purposes, but it should be integrated into the site 
	compilation system eventually.
 */

@interface TBAsset : NSObject

/*!
	 Create a tree of TBAsset objects, rooted in the given directory.
	 @param URL
		 A directory in which to begin building the asset tree.
	 @param error
		If the return value is nil, then this argument will contain an NSError
		object describing what went wrong.
	 @return
		An array of assets, or nil if an error was encountered.
 */
+ (NSArray *)assetsFromDirectory:(NSURL*)URL error:(NSError **)error;

/*!
 @property URL
 The filesystem URL of the asset.
 */
@property (nonatomic, strong) NSURL *URL;

/*!
	@property displayName
		The localized display name of the asset (i.e. what the user would see if 
		they examined the file in Finder.)
 */
@property (nonatomic, copy) NSString *displayName;

/*!
	 @property type
		The Uniform Type Identifier (UTI) of the asset.
 */
@property (nonatomic, copy) NSString *type;

/*!
	@property children
		An array of child assets, or nil if the asset is a leaf.
 */
@property (nonatomic, strong) NSArray *children;

/*!
	@return
		YES if the asset has no children, NO if it does.
 */
- (BOOL)isLeaf;

@end
