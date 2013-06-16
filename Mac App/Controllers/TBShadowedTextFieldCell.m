//
//  TBShadowedTextFieldCell.m
//  Tribo
//
//  Created by Carter Allen on 3/17/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBShadowedTextFieldCell.h"

@implementation TBShadowedTextFieldCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSColor *shadowColor = self.aquaShadowColor;
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		shadowColor = self.graphiteShadowColor;
	if (!controlView.window.isKeyWindow)
		shadowColor = [shadowColor highlightWithLevel:0.3];
	NSShadow *shadow = [NSShadow new];
	shadow.shadowOffset = NSMakeSize(0.0, -1.0);
	shadow.shadowBlurRadius = 0.0;
	shadow.shadowColor = shadowColor;
	[shadow set];
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
	NSSize cellSize = [super cellSizeForBounds:aRect];
	cellSize.height += 1.0;
	return cellSize;
}

@end
