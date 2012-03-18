//
//  TBShadowedButtonCell.m
//  Tribo
//
//  Created by Carter Allen on 3/17/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBShadowedButtonCell.h"

@implementation TBShadowedButtonCell
@synthesize aquaShadowColor = _aquaShadowColor;
@synthesize graphiteShadowColor = _graphiteShadowColor;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSColor *shadowColor = self.aquaShadowColor;
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		shadowColor = self.graphiteShadowColor;
	NSShadow *shadow = [NSShadow new];
	shadow.shadowOffset = NSMakeSize(0.0, -1.0);
	shadow.shadowBlurRadius = 0.0;
	shadow.shadowColor = shadowColor;
	[shadow set];
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if (!flag) {
		[self drawInteriorWithFrame:cellFrame inView:controlView];
		return;
	}
	NSShadow *inset = [NSShadow new];
	inset.shadowOffset = NSMakeSize(0.0, -1.0);
	inset.shadowBlurRadius = 0.0;
	inset.shadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.25];
	[inset set];
	[super drawImage:self.image withFrame:[self imageRectForBounds:cellFrame] inView:controlView];
}

@end
