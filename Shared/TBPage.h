//
//  TBPage.h
//  Tribo
//
//  Created by Carter Allen on 9/30/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

@class TBSite;

/*!
	@class TBPage
	@discussion A page represents a piece of content that will be rendered into 
	HTML by the main template rendering engine. The content of each page will 
	replace the {{{content}}} tag in the default template file, and then the 
	resulting string will be rendered with the template engine. Pages themselves 
	should generally be static, non-post pages of the website. Examples include 
	"About" pages, archives, and galleries.
	
	All files in the Source directory of a site with the ".mustache" extension 
	will be loaded and rendered as TBPage objects.
 */

@interface TBPage : NSObject

/*!
	 Create a TBPage object from a file on-disk.
	 @param URL
		A filesystem URL pointing to the page file.
	 @param site
		The TBSite object which contains the page.
	 @param error
		If the return value is NO, then this argument will contain an NSError
		object describing what went wrong.
	 @return
		YES on successful processing, NO if an error was encountered.
 */
+ (instancetype)pageWithURL:(NSURL *)URL
					 inSite:(TBSite *)site
					  error:(NSError**)error;

/*!
	@property URL
		The filesystem URL of the file whose content the page is loaded from.
 */
@property (nonatomic, strong) NSURL *URL;

/*!
	@property site
		The TBSite object containing the page.
 */
@property (nonatomic, weak) TBSite *site;

/*!
	@property title
		The (optional) title of the page, parsed and then removed from the 
		content loaded from disk. Titles take the form of an HTML comment at the
		top of the file, for example, "<!-- Title -->".
 */
@property (nonatomic, strong) NSString *title;

/*!
	@property content
		The content loaded from disk, before being processed by the renderer.
 */
@property (nonatomic, strong) NSString *content;

/*!
	@property stylesheets
		An (optional) array of dictionaries, each representing a stylesheet in 
		the Source directory of the site. Parsed based on the second (or first, 
		if the title is omitted) line of the file, stylesheet declarations take 
		the form of an HTML comment, like so: 
		"<!-- Stylesheets: sheet1, sheet2 -->". This array is intended to then 
		be used by the default template to provide pages with custom stylesheets
		using Mustache code like so:
		
		  {{#stylesheets}}
		    <link rel="stylesheet" href="/stylesheets/{{stylesheetName}}.css">
		  {{/stylesheets}}
 */
@property (nonatomic, strong) NSArray *stylesheets;

@end
