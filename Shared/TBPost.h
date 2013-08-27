//
//  TBPost.h
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBPage.h"

#import "TSPostMetadata.h"

/*!
	@class TBPost
	@discussion A post represents a piece of writing, loaded from disk, with its
	content styled using Markdown. Posts are loaded from a Tribo site file's 
	Posts directory (typically just /Posts inside the bundle), and their content 
	is converted to HTML before being rendered using the Post template found in 
	the site's Templates directory.
	
	As a data structure, posts are fairly simple. TBPost inherits from TBPage, 
	which gives the class properties that apply to any rendered file in a site. 
	In addition to the standard page properties, posts have author, date, and 
	slug properties, along with a property to access the unprocessed Markdown 
	content of the post. More information about the derivation of each property 
	can be found in the specific descriptions.
 */

@interface TBPost : TBPage

/*!
	Create a TBPost object from a file on-disk.
	@param URL
		A filesystem URL pointing to the post file.
	@param site
		The TBSite object which contains the post.
	@param error
		If the return value is nil, then this argument will contain an NSError
		object describing what went wrong.
	@return
		A TBPost object, or nil if an error was encountered.
 */
- (instancetype)initWithURL:(NSURL *)URL inSite:(TBSite *)site error:(NSError **)error;

- (instancetype)initWithTitle:(NSString *)title slug:(NSString *)slug inSite:(TBSite *)site error:(NSError **)error;

/*!
	Parse the contents of the markdownContent property, saving the HTML output
	to the content property.
 */
- (void)parseMarkdownContent;

/*!
	@property author
		The name of the person who wrote the post. This property is not
		currently implemented.
 */
@property (nonatomic, strong) NSString *author;

/*!
	@property date
		The publishing date of the post. Derived from the filename of the post,
		which must begin with a calendar date in the form YYYY-MM-DD.
 */
@property (nonatomic, strong) NSDate *date;

/*!
	@property slug
		Appears in the site output in the URL of the post. Should be a URL-safe 
		string, and is typically a shortened version of the post's title with 
		any spaces replaced with dashes. Derived from the filename of the post, 
		where the slug must immediately follow the date, separated by a dash.
 */
@property (nonatomic, strong) NSString *slug;

@property (nonatomic, strong) TSPostMetadata *metadata;

@property (nonatomic, strong) NSURL *postDirectory;

/*!
	@property markdownContent
		The original content of the post, before being converted to HTML by the 
		Markdown parser.
 */
@property (nonatomic, strong) NSString *markdownContent;

@end
