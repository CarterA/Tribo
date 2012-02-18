//
//  TBTabView.m
//  Tribo
//
//  Created by Carter Allen on 10/29/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBTabView.h"
#import <QuartzCore/QuartzCore.h>

@interface TBTab : NSTextField
@end

@interface TBTabView () {
	TBTab *_clickedTab;
}
@property (nonatomic, strong) NSMutableArray *tabs;
- (void)tabReceivedMouseDown:(TBTab *)tab;
- (void)tabReceivedMouseUp:(TBTab *)tab;
@end

@interface TBVerticallyCenteredTextFieldCell : NSTextFieldCell
@end

@implementation TBTabView
@synthesize titles=_titles;
@synthesize selectedIndex=_selectedIndex;
@synthesize delegate=_delegate;
@synthesize tabs=_tabs;

- (void)setTitles:(NSArray *)titles {
	self.tabs = [NSMutableArray arrayWithCapacity:titles.count];
	CGFloat tabWidth = ceil(self.frame.size.width/titles.count);
	CGFloat tabHeight = self.frame.size.height;
	[titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
		TBTab *tab = [[TBTab alloc] initWithFrame:NSMakeRect(index * tabWidth, 0, tabWidth, tabHeight)];
		tab.target = self;
		tab.stringValue = title;
		tab.autoresizingMask = NSViewWidthSizable;
		if (index == 0) tab.autoresizingMask = tab.autoresizingMask|NSViewMaxXMargin;
		else if (index == (titles.count - 1)) tab.autoresizingMask = tab.autoresizingMask|NSViewMinXMargin;
		else tab.autoresizingMask = tab.autoresizingMask|NSViewMinXMargin|NSViewMaxXMargin;
		[self.tabs addObject:tab];
		[self addSubview:tab];
	}];
	[self setNeedsDisplay:YES];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	[self setNeedsDisplay:YES];
	[self.delegate tabView:self didSelectIndex:selectedIndex];
}

- (void)tabReceivedMouseDown:(TBTab *)tab {
	_clickedTab = tab;
	[self setNeedsDisplay:YES];
}

- (void)tabReceivedMouseUp:(TBTab *)tab {
	_clickedTab = nil;
	NSUInteger index = [self.tabs indexOfObject:tab];
	self.selectedIndex = index;
}

- (void)drawRect:(NSRect)rect {
	
	// Fill everything with the base white gradient.
	NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.98 alpha:1.000] endingColor:[NSColor colorWithDeviceWhite:0.940 alpha:1.000]];
	[backgroundGradient drawInRect:self.bounds angle:270.0];
	
	// Draw a darker gradient over the selected tab.
	NSGradient *selectionGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.89 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.85 alpha:1.0]];
	[selectionGradient drawInRect:[[self.tabs objectAtIndex:self.selectedIndex] frame] angle:270.0];
	
	// Draw an inverted gradient over the clicked tab, if there is one.
	if (_clickedTab) {
		NSGradient *clickedGradient = nil;
		if ([self.tabs indexOfObject:_clickedTab] == self.selectedIndex)
			clickedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.85 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.89 alpha:1.0]];
		else
			clickedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.94 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.98 alpha:1.0]];
		[clickedGradient drawInRect:_clickedTab.frame angle:270.0];
	}
	
	// Draw the bottom border and inset line.
	NSColor *borderColor = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
	[borderColor set];
	NSRect topBorderRect = NSMakeRect(0.0, 0.0, self.frame.size.width, 1.0);
	NSRectFill(topBorderRect);
	
	// Draw border lines and titles for each tab.
	[self.tabs enumerateObjectsUsingBlock:^(TBTab *tab, NSUInteger index, BOOL *stop) {
		if (index != (self.tabs.count - 1)) {
			NSRect lineRect = NSMakeRect(tab.frame.size.width, 0.0, 1.0, tab.frame.size.height);
			NSRectFill(lineRect);
		}
	}];
	
}

@end

@implementation TBTab

- (id)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.alignment = NSCenterTextAlignment;
		self.editable = NO;
		self.drawsBackground = NO;
		self.textColor = [NSColor controlTextColor];
		[self.cell setBordered:NO];
		[self.cell setBackgroundStyle:NSBackgroundStyleRaised];
		[self.cell setFont:[NSFont boldSystemFontOfSize:11.0]];
	}
	return self;
}

+ (Class)cellClass {
	return [TBVerticallyCenteredTextFieldCell class];
}

- (void)mouseDown:(NSEvent *)theEvent {
	TBTabView *tabView = (TBTabView *)self.superview;
	[tabView tabReceivedMouseDown:self];
}

- (void)mouseUp:(NSEvent *)theEvent {
	TBTabView *tabView = (TBTabView *)self.superview;
	[tabView tabReceivedMouseUp:self];
}

@end

@implementation TBVerticallyCenteredTextFieldCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
	NSRect titleFrame = [super titleRectForBounds:theRect];
	NSSize titleSize = [[self attributedStringValue] size];
	titleFrame.origin.y = theRect.origin.y + (theRect.size.height - titleSize.height) / 2.0;
	return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSRect titleRect = [self titleRectForBounds:cellFrame];
	[super drawInteriorWithFrame:titleRect inView:controlView];
}

@end
