//
//  TBStyleDictionary.m
//  Tribo
//
//  Created by Carter Allen on 7/17/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBStyleDictionary.h"

NSString * const TBStyleDictionaryFontKey		= @"font";
NSString * const TBStyleDictionarySizeKey		= @"size";
NSString * const TBStyleDictionaryColorKey		= @"color";
NSString * const TBStyleDictionaryUnderlineKey	= @"underline";

@interface TBStyleDictionary ()
@property (nonatomic, strong) NSDictionary *styleDictionary;
@end

@implementation TBStyleDictionary

+ (instancetype)styleDictionaryFromURL:(NSURL *)URL {
	return [[[self class] alloc] initWithURL:URL];
}

- (id)initWithURL:(NSURL *)URL {
	self = [super init];
	if (self) {
		[self loadStylesFromURL:URL];
	}
	return self;
}

- (NSDictionary *)attributesForElement:(NSString *)element {
	return self.styleDictionary[element];
}

- (NSDictionary *)objectForKeyedSubscript:(NSString *)element {
	return [self attributesForElement:element];
}

- (void)loadStylesFromURL:(NSURL *)URL {
	
	NSData *JSONData = [NSData dataWithContentsOfURL:URL];
	NSError *error;
	NSMutableDictionary *rawStyles = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
	
	NSDictionary *rawDefaults = rawStyles[@"body"];
	
	NSDictionary *flattenedStyles = [self flattenedStylesFromDictionary:rawStyles];
	NSDictionary *styleDictionary = [self parsedStyleDictionaryFromFlatStyles:flattenedStyles withDefaultStyle:rawDefaults];
	
	self.styleDictionary = styleDictionary;
		
}

- (NSDictionary *)flattenedStylesFromDictionary:(NSDictionary *)source {
	
	NSMutableDictionary *styles = [source mutableCopy];
	NSMutableDictionary *stylesToAdd = [NSMutableDictionary dictionary];
	NSMutableArray *stylesToRemove = [NSMutableArray array];
	[styles enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *attributes, BOOL *stop) {
		if ([key rangeOfString:@";"].length == 0) return;
		for (NSString *subkey in [key componentsSeparatedByString:@";"]) {
			if (!styles[subkey]) stylesToAdd[subkey] = attributes;
			else [styles[subkey] addEntriesFromDictionary:attributes];
		}
		[stylesToRemove addObject:key];
	}];
	[styles addEntriesFromDictionary:stylesToAdd];
	[styles removeObjectsForKeys:stylesToRemove];
	return styles;
	
}

- (NSDictionary *)parsedStyleDictionaryFromFlatStyles:(NSDictionary *)rawStyles withDefaultStyle:(NSDictionary *)rawDefaults {
	
	NSMutableDictionary *styles = [NSMutableDictionary dictionary];
	[rawStyles enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableDictionary *rawAttributes, BOOL *stop) {
		
		rawAttributes = [rawAttributes mutableCopy];
		[rawDefaults enumerateKeysAndObjectsUsingBlock:^(NSString *defaultKey, NSDictionary *defaultAttributes, BOOL *defaultStop) {
			if (rawAttributes[defaultKey]) return;
			rawAttributes[defaultKey] = rawDefaults[defaultKey];
		}];
		
		NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
		
		// Fonts
		NSString *fontName = rawAttributes[TBStyleDictionaryFontKey];
		CGFloat fontSize = [rawAttributes[TBStyleDictionarySizeKey] floatValue];
		NSFont *font = [NSFont fontWithName:fontName size:fontSize];
		if (!font) font = [NSFont systemFontOfSize:fontSize];
		attributes[NSFontAttributeName] = font;
		
		styles[key] = attributes;
		
		// Colors
		NSArray *rawColors = rawAttributes[TBStyleDictionaryColorKey];
		NSColor *color = [NSColor colorWithCalibratedRed:[rawColors[0] floatValue] green:[rawColors[1] floatValue] blue:[rawColors[2] floatValue] alpha:1.0];
		attributes[NSForegroundColorAttributeName] = color;
		
		// Underlines
		NSString *rawUnderline = rawAttributes[TBStyleDictionaryUnderlineKey];
		if ([rawUnderline isEqualToString:@"solid"])
			attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
		
	}];
	
	return styles;
	
}

@end
