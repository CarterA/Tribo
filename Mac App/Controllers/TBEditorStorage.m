//
//  TBEditorStorage.m
//  Tribo
//
//  Created by Carter Allen on 7/1/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBEditorStorage.h"
#import "TBStyleDictionary.h"

// Turn a range inside a substring into a range inside the containing string.
#define TBAbsoluteRange(relativeRange, containerRange) \
	NSMakeRange(relativeRange.location + containerRange.location, relativeRange.length)

@interface TBEditorStorage ()
@property (nonatomic, strong) NSMutableAttributedString *backingStore;
@property (nonatomic, strong) TBStyleDictionary *styleDictionary;
@property (nonatomic, assign) BOOL syntaxHighlightingNeedsUpdate;
@end

@implementation TBEditorStorage

- (id)init {
	self = [super init];
	if (self) {
		self.backingStore = [[NSMutableAttributedString alloc] init];
		self.styleDictionary = [TBStyleDictionary styleDictionaryFromURL:[[NSBundle mainBundle] URLForResource:@"Editor Styles" withExtension:@"json"]];
	}
	return self;
}

#pragma mark - NSTextStorage

- (NSString *)string {
	return self.backingStore.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
	return [self.backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
	[self.backingStore replaceCharactersInRange:range withString:str];
	self.syntaxHighlightingNeedsUpdate = YES;
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
	[self.backingStore setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)processEditing {
	if (self.syntaxHighlightingNeedsUpdate) {
		self.syntaxHighlightingNeedsUpdate = NO;
		[self performReplacementsForCharacterChangeInRange:self.editedRange];
	}
	[super processEditing];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)range {
	NSRange extendedRange = NSUnionRange(range, [self.backingStore.string lineRangeForRange:NSMakeRange(range.location, 0)]);
	[self applySyntaxHighlightingToRange:extendedRange];
}

- (void)applySyntaxHighlightingToRange:(NSRange)range {
	
	NSString *substring = [self.backingStore.string substringWithRange:range];
	[self.backingStore setAttributes:self.styleDictionary[@"body"] range:range];
	
	// Headers
	
	// ATX-style headers (# Header 1 #, ## Header 2 ##, etc.)
	NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\#{1,6})[ \\t]*(.+?)[ \\t]*\\#*\\n+" options:0 error:nil];
	[headerRegex enumerateMatchesInString:substring options:0 range:NSMakeRange(0, substring.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (result.numberOfRanges != 3) return;
		NSString *hashmarks = [substring substringWithRange:[result rangeAtIndex:1]];
		NSUInteger headerLevel = hashmarks.length;
		NSRange headerRange = TBAbsoluteRange([result rangeAtIndex:0], range);
		NSDictionary *attributes = self.styleDictionary[[NSString stringWithFormat:@"h%ld", headerLevel]];
		[self.backingStore addAttributes:attributes range:headerRange];
	}];
	
	// Strength and Emphasis
	
	NSRegularExpression *emphasisRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\*|_)(?=\\S)(.+?)(?<=\\S)\\1" options:0 error:nil];
	[emphasisRegex enumerateMatchesInString:substring options:0 range:NSMakeRange(0, substring.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange emphasisRange = TBAbsoluteRange([result rangeAtIndex:0], range);
		NSDictionary *attributes = self.styleDictionary[@"em"];
		[self.backingStore addAttributes:attributes range:emphasisRange];
	}];
	NSRegularExpression *strongRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\*\\*|__)(?=\\S)(.+?[*_]*)(?<=\\S)\\1" options:0 error:nil];
	[strongRegex enumerateMatchesInString:substring options:0 range:NSMakeRange(0, substring.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange strongRange = TBAbsoluteRange([result rangeAtIndex:0], range);
		NSDictionary *attributes = self.styleDictionary[@"strong"];
		[self.backingStore addAttributes:attributes range:strongRange];
	}];
	
	// Links
	
	NSRegularExpression *inlineLinkRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\(([\\S]*?)\\s?\\\"?(.*?)\\\"?\\)(.|\\s)" options:0 error:nil];
	[inlineLinkRegex enumerateMatchesInString:substring options:0 range:NSMakeRange(0, substring.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange linkTextRange = TBAbsoluteRange([result rangeAtIndex:1], range);
		[self.backingStore addAttributes:self.styleDictionary[@"link-text"] range:linkTextRange];
		NSRange linkHrefRange = TBAbsoluteRange([result rangeAtIndex:2], range);
		[self.backingStore addAttributes:self.styleDictionary[@"link-href"] range:linkHrefRange];
		if (result.numberOfRanges > 3) {
			NSRange linkTitleRange = TBAbsoluteRange([result rangeAtIndex:3], range);
			[self.backingStore addAttributes:self.styleDictionary[@"link-title"] range:linkTitleRange];
		}
	}];
	
	// Lists
	
	NSError *error;
	NSRegularExpression *listRegex = [NSRegularExpression regularExpressionWithPattern:@"(([ \\t]{0,3}(?:[*+-]|\\d+[.])[ \\t]+)(?s:.+?)(\\z|\\n{2,}(?=\\S)(?![ \\t]*(?:[*+-]|\\d+[.])[ \\t]+)))" options:NSRegularExpressionAnchorsMatchLines error:&error];
	[listRegex enumerateMatchesInString:self.backingStore.string options:NSMatchingWithTransparentBounds range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[self.backingStore addAttributes:self.styleDictionary[@"list"] range:[result rangeAtIndex:1]];
	}];
	
}

@end
