//
//  TBEditorStorage.m
//  Tribo
//
//  Created by Carter Allen on 7/1/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

#import "TBEditorStorage.h"

@interface TBEditorStorage ()
@property (nonatomic, strong) NSMutableAttributedString *backingStore;
@property (nonatomic, assign) BOOL syntaxHighlightingNeedsUpdate;
@end

@implementation TBEditorStorage

- (id)init {
	self = [super init];
	if (self) {
		self.backingStore = [[NSMutableAttributedString alloc] init];
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
	
	NSString *markdown = [self.backingStore.string substringWithRange:range];
	
	// Headers
	
	// ATX-style headers (# Header 1 #, ## Header 2 ##, etc.)
	NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\#{1,6})[ \\t]*(.+?)[ \\t]*\\#*\\n+" options:0 error:nil];
	[headerRegex enumerateMatchesInString:markdown options:0 range:NSMakeRange(0, markdown.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (result.numberOfRanges != 3) return;
		CGFloat headerSizeMultipliers[] = {
			1.0, // Body text
			1.6, // <h1>
			1.5, // <h2>
			1.4, // <h3>
			1.3, // <h4>
			1.2, // <h5>
			1.1  // <h6>
		};
		NSString *hashmarks = [markdown substringWithRange:[result rangeAtIndex:1]];
		NSUInteger headerLevel = hashmarks.length;
		NSRange headerRange = [self.backingStore.string rangeOfString:[markdown substringWithRange:[result rangeAtIndex:0]]];
		[self.backingStore addAttributes:@{
			NSFontAttributeName: [NSFont fontWithName:@"Avenir Next Demi Bold" size:14.0 * headerSizeMultipliers[headerLevel]],
		} range:headerRange];
	}];
	
}

@end
