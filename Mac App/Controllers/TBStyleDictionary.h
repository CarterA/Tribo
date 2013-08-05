//
//  TBStyleDictionary.h
//  Tribo
//
//  Created by Carter Allen on 7/17/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import <Foundation/Foundation.h>

/*!
	@class TBStyleDictionary
	@discussion A style dictionary represents a set of attributed string 
	attributes; keyed by short, HTML-like element names; and parsed from a 
	human-readable and easily-edited JSON file. 
 
	The JSON file must be a single root object, with keys for each element that
	will be styled. The key must point to an object containing the attributes 
	that will be parsed for the corresponding element. For example, a JSON file 
	which would style an element called "strong" with a bold font would look 
	like this: 
		
		{ "strong": { "font": "Helvetica Bold" } }
	
	A set of attributes may be applied to multiple elements by creating an 
	element key with each element name separated by a semicolon. For example, 
	an element key of "h1;h2;h3" would have its corresponding attributes applied 
	to the "h1", "h2", and "h3" elements.
	
	Attributes in the JSON file are parsed and converted into AppKit and UIKit 
	string attributes. The following attributes are currently supported:
	
	+-----------+--------+-------------------------------------------+
	| Attribute |  Type  |                   Notes                   |
	+-----------+--------+-------------------------------------------+
	|   font    | string | Full name of a specific, installed, font. |
	|   size    | float  | Font size, in typographic points.         |
	|   color   | array  | Array of numbers, [red, green, blue].     |
	| underline | string | One possible value: "solid".              |
	|  indent   | float  | Left-indentation, in CoreGraphics points. |
	+-----------+--------+-------------------------------------------+
	
	Note that TBStyleDictionary instances support keyed subscripting, so the 
	attributes for an element can be retrieved using subscript syntax.
 */

@interface TBStyleDictionary : NSObject

/*!
	Create a style dctionary from the contents of the specified JSON file.
	@param URL
		A filesystem URL pointing to a valid JSON file.
 */
+ (instancetype)styleDictionaryFromURL:(NSURL *)URL;

/*!
	Retrieve the attributes for a specific element.
	@param element
		The short name for the element, also used as the element's key in the 
		supplied JSON file.
 */
- (NSDictionary *)attributesForElement:(NSString *)element;

- (NSDictionary *)objectForKeyedSubscript:(NSString *)element;

@end
