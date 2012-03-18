//
//  TBStatusView.m
//  Tribo
//
//  Created by Carter Allen on 3/15/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBStatusView.h"

@interface TBStatusView ()
@property (nonatomic, strong) NSColor *aquaTopColor;
@property (nonatomic, strong) NSColor *aquaBottomColor;
@property (nonatomic, strong) NSColor *aquaBorderColor;
@property (nonatomic, strong) NSColor *aquaHighlightColor;
@property (nonatomic, strong) NSColor *graphiteTopColor;
@property (nonatomic, strong) NSColor *graphiteBottomColor;
@property (nonatomic, strong) NSColor *graphiteBorderColor;
@property (nonatomic, strong) NSColor *graphiteHighlightColor;
@property (nonatomic, assign) IBOutlet NSTextField *titleField;
@end

@implementation TBStatusView
@synthesize aquaTopColor = _aquaTopColor;
@synthesize aquaBottomColor = _aquaBottomColor;
@synthesize aquaBorderColor = _aquaBorderColor;
@synthesize aquaHighlightColor = _aquaHighlightColor;
@synthesize graphiteTopColor = _graphiteTopColor;
@synthesize graphiteBottomColor = _graphiteBottomColor;
@synthesize graphiteBorderColor = _graphiteBorderColor;
@synthesize graphiteHighlightColor = _graphiteHighlightColor;
@synthesize titleField = _titleField;

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserverForName:NSControlTintDidChangeNotification object:NSApp queue:nil usingBlock:^(NSNotification *note) {
		[self setNeedsDisplay:YES];
	}];
	NSRect titleFrame = self.titleField.frame;
	titleFrame.size.height += 2.0;
	titleFrame.origin.y -= 2.0;
	self.titleField.frame = titleFrame;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSColor *topColor = self.aquaTopColor;
	NSColor *bottomColor = self.aquaBottomColor;
	NSColor *borderColor = self.aquaBorderColor;
	NSColor *highlightColor = self.aquaHighlightColor;
	if ([NSColor currentControlTint] == NSGraphiteControlTint) {
		topColor = self.graphiteTopColor;
		bottomColor = self.graphiteBottomColor;
		borderColor = self.graphiteBorderColor;
		highlightColor = self.graphiteHighlightColor;
	}
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];
	[gradient drawInRect:self.bounds angle:270.0];
	[borderColor set];
	NSRect borderRect = NSMakeRect(0.0, self.bounds.size.height - 1.0, self.bounds.size.width, 1.0);
	NSRectFill(borderRect);
	[highlightColor set];
	NSRect highlightRect = NSMakeRect(0.0, self.bounds.size.height - 2.0, self.bounds.size.width, 1.0);
	NSRectFill(highlightRect);
}

@end
