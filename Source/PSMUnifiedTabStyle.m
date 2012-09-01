//
//  PSMUnifiedTabStyle.m
//  --------------------
//
//  Created by Keith Blount on 30/04/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PSMUnifiedTabStyle.h"
#import "PSMTabBarCell.h"
#import "PSMTabBarControl.h"
#import "NSBezierPath_AMShading.h"

@interface PSMUnifiedTabStyle (Private)
- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView;
@end

@implementation PSMUnifiedTabStyle

@synthesize leftMarginForTabBarControl = _leftMargin;

- (NSString *)name {
	return @"Unified";
}

#pragma mark -
#pragma mark Creation/Destruction

- (id) init {
	if((self = [super init])) {
		unifiedCloseButton = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front"]];
		unifiedCloseButtonDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front_Pressed"]];
		unifiedCloseButtonOver = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabClose_Front_Rollover"]];

		unifiedCloseDirtyButton = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front"]];
		unifiedCloseDirtyButtonDown = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front_Pressed"]];
		unifiedCloseDirtyButtonOver = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabCloseDirty_Front_Rollover"]];

		_addTabButtonImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNew"]];
		_addTabButtonPressedImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewPressed"]];
		_addTabButtonRolloverImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"AquaTabNewRollover"]];

		_objectCountStringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask], NSFontAttributeName,
										[[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
										nil, nil];

		_leftMargin = 0.0;
	}
	return self;
}

- (void)dealloc {
	[unifiedCloseButton release];
	[unifiedCloseButtonDown release];
	[unifiedCloseButtonOver release];
	[unifiedCloseDirtyButton release];
	[unifiedCloseDirtyButtonDown release];
	[unifiedCloseDirtyButtonOver release];
	[_addTabButtonImage release];
	[_addTabButtonPressedImage release];
	[_addTabButtonRolloverImage release];

	[_objectCountStringAttributes release];

	[super dealloc];
}

#pragma mark -
#pragma mark Control Specific

- (CGFloat)rightMarginForTabBarControl {
	return 24.0f;
}

- (CGFloat)topMarginForTabBarControl {
	return 10.0f;
}

#pragma mark -
#pragma mark Add Tab Button

- (NSImage *)addTabButtonImage {
	return _addTabButtonImage;
}

- (NSImage *)addTabButtonPressedImage {
	return _addTabButtonPressedImage;
}

- (NSImage *)addTabButtonRolloverImage {
	return _addTabButtonRolloverImage;
}

#pragma mark -
#pragma mark Drag Support

- (NSRect)dragRectForTabCell:(PSMTabBarCell *)cell orientation:(PSMTabBarOrientation)orientation {
	NSRect dragRect = [cell frame];
	dragRect.size.width++;
	return dragRect;
}

#pragma mark -
#pragma mark Providing Images

- (NSImage *)closeButtonImageOfType:(PSMCloseButtonImageType)type forTabCell:(PSMTabBarCell *)cell
{
    switch (type) {
        case PSMCloseButtonImageTypeStandard:
            return unifiedCloseButton;
        case PSMCloseButtonImageTypeRollover:
            return unifiedCloseButtonOver;
        case PSMCloseButtonImageTypePressed:
            return unifiedCloseButtonDown;
            
        case PSMCloseButtonImageTypeDirty:
            return unifiedCloseDirtyButton;
        case PSMCloseButtonImageTypeDirtyRollover:
            return unifiedCloseDirtyButtonOver;
        case PSMCloseButtonImageTypeDirtyPressed:
            return unifiedCloseDirtyButtonDown;
            
        default:
            break;
    }
    
}  // -closeButtonImageOfType:

#pragma mark -
#pragma mark Determining Cell Size

- (CGFloat)tabCellHeight {
	return kPSMTabBarControlHeight;
}

#pragma mark -
#pragma mark Cell Values

- (NSAttributedString *)attributedObjectCountValueForTabCell:(PSMTabBarCell *)cell {
	NSString *contents = [NSString stringWithFormat:@"%lu", (unsigned long)[cell count]];
	return [[[NSMutableAttributedString alloc] initWithString:contents attributes:_objectCountStringAttributes] autorelease];
}

- (NSAttributedString *)attributedStringValueForTabCell:(PSMTabBarCell *)cell {
	NSMutableAttributedString *attrStr;
	NSString * contents = [cell stringValue];
	attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
	NSRange range = NSMakeRange(0, [contents length]);

	[attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];

	// Paragraph Style for Truncating Long Text
	static NSMutableParagraphStyle *TruncatingTailParagraphStyle = nil;
	if(!TruncatingTailParagraphStyle) {
		TruncatingTailParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] retain];
		[TruncatingTailParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	[attrStr addAttribute:NSParagraphStyleAttributeName value:TruncatingTailParagraphStyle range:range];

	return attrStr;
}

#pragma mark -
#pragma mark Drawing

-(void)drawBezelOfTabCell:(PSMTabBarCell *)cell withFrame:(NSRect)frame inView:(id)controlView
{
    NSWindow *window = [controlView window];
    NSToolbar *toolbar = [window toolbar];
    
	NSBezierPath *bezier = [NSBezierPath bezierPath];
	NSColor *lineColor = [NSColor colorWithCalibratedWhite:0.576 alpha:1.0];
    
    if (toolbar && [toolbar isVisible]) {

        NSRect aRect = NSMakeRect(frame.origin.x + 0.5, frame.origin.y - 0.5, frame.size.width, frame.size.height);
        CGFloat radius = MIN(6.0, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
        NSRect rect = NSInsetRect(aRect, radius, radius);
        
        NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
        [bezier appendBezierPathWithPoints:&cornerPoint count:1];

        [bezier appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:0.0 endAngle:90.0];

        [bezier appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle:90.0 endAngle:180.0];

        cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
        [bezier appendBezierPathWithPoints:&cornerPoint count:1];    

        if ([[controlView window] isKeyWindow]) {
            if ([cell state] == NSOnState) {
                NSColor *startColor = [NSColor colorWithDeviceWhite:0.698 alpha:1.000];
                NSColor *endColor = [NSColor colorWithDeviceWhite:0.663 alpha:1.000];
                NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
                [gradient drawInBezierPath:bezier angle:80.0];
                [gradient release];
            } else if ([cell isHighlighted]) {
                NSColor *startColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.000];
                NSColor *endColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.000];
                NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
                [gradient drawInBezierPath:bezier angle:80.0];
                [gradient release];            
            }
            
        } else {
            if ([cell state] == NSOnState) {
                NSColor *startColor = [NSColor colorWithDeviceWhite:0.875 alpha:1.000];
                NSColor *endColor = [NSColor colorWithDeviceWhite:0.902 alpha:1.000];
                NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
                [[NSGraphicsContext currentContext] setShouldAntialias:NO];
                [gradient drawInBezierPath:bezier angle:90.0];
                [[NSGraphicsContext currentContext] setShouldAntialias:YES];
                [gradient release];
            }
        }        
            
        [lineColor set];
        [bezier stroke];
    } else {
    
		NSRect aRect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
		aRect.origin.y += 0.5;
		aRect.origin.x += 1.5;
		aRect.size.width -= 1;

		aRect.origin.x -= 1;
		aRect.size.width += 1;


        if ([cell state] == NSOnState) {
			[[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
			NSRectFillUsingOperation(aRect, NSCompositeSourceAtop);            
        } else if([cell isHighlighted]) {
			[[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
			NSRectFillUsingOperation(aRect, NSCompositeSourceAtop);
		}

		// frame
		[lineColor set];
		[bezier moveToPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y - 0.5)];
		if(!([cell tabState] & PSMTab_RightIsSelectedMask)) {
			[bezier lineToPoint:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
		}

		[bezier stroke];

		// Create a thin lighter line next to the dividing line for a bezel effect
		if(!([cell tabState] & PSMTab_RightIsSelectedMask)) {
			[[[NSColor whiteColor] colorWithAlphaComponent:0.5] set];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(aRect) + 1.0, aRect.origin.y - 0.5)
			 toPoint:NSMakePoint(NSMaxX(aRect) + 1.0, NSMaxY(aRect) - 2.5)];
		}

		// If this is the leftmost tab, we want to draw a line on the left, too
		if([cell tabState] & PSMTab_PositionLeftMask) {
			[lineColor set];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(aRect.origin.x, aRect.origin.y - 0.5)
			 toPoint:NSMakePoint(aRect.origin.x, NSMaxY(aRect) - 2.5)];
			[[[NSColor whiteColor] colorWithAlphaComponent:0.5] set];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(aRect.origin.x + 1.0, aRect.origin.y - 0.5)
			 toPoint:NSMakePoint(aRect.origin.x + 1.0, NSMaxY(aRect) - 2.5)];
		}    
    }
}  // -drawBezelOfTabCell:withFrame:inView:

- (void)drawBezelOfTabBarControl:(PSMTabBarControl *)tabBarControl inRect:(NSRect)rect {
	//Draw for our whole bounds; it'll be automatically clipped to fit the appropriate drawing area
	rect = [tabBarControl bounds];

	NSRect gradientRect = rect;
	gradientRect.size.height -= 1.0;

	NSBezierPath *path = [NSBezierPath bezierPathWithRect:gradientRect];
	[path linearGradientFillWithStartColor:[NSColor colorWithCalibratedWhite:0.835 alpha:1.0]
	 endColor:[NSColor colorWithCalibratedWhite:0.843 alpha:1.0]];
	[[NSColor colorWithCalibratedWhite:0.576 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x, NSMaxY(rect) - 0.5)
	 toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 0.5)];

	if(![[[tabBarControl tabView] window] isKeyWindow]) {
		[[NSColor windowBackgroundColor] set];
		NSRectFill(gradientRect);
	}
}

- (void)drawInteriorOfTabBarControl:(PSMTabBarControl *)tabBarControl inRect:(NSRect)rect {

	// no tab view == not connected
	if(![tabBarControl tabView]) {
		NSRect labelRect = rect;
		labelRect.size.height -= 4.0;
		labelRect.origin.y += 4.0;
		NSMutableAttributedString *attrStr;
		NSString *contents = @"PSMTabBarControl";
		attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
		NSRange range = NSMakeRange(0, [contents length]);
		[attrStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:range];
		NSMutableParagraphStyle *centeredParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [centeredParagraphStyle setAlignment:NSCenterTextAlignment];
        
		[attrStr addAttribute:NSParagraphStyleAttributeName value:centeredParagraphStyle range:range];
		[attrStr drawInRect:labelRect];
        
        [centeredParagraphStyle release];
		return;
	}

	// draw cells
	NSEnumerator *e = [[tabBarControl cells] objectEnumerator];
	PSMTabBarCell *cell;
	while((cell = [e nextObject])) {
		if([tabBarControl isAnimating] || (![cell isInOverflowMenu] && NSIntersectsRect([cell frame], rect))) {
			[cell drawWithFrame:[cell frame] inView:tabBarControl];
		}
	}
}

#pragma mark -
#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder {
	//[super encodeWithCoder:aCoder];
	if([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:unifiedCloseButton forKey:@"unifiedCloseButton"];
		[aCoder encodeObject:unifiedCloseButtonDown forKey:@"unifiedCloseButtonDown"];
		[aCoder encodeObject:unifiedCloseButtonOver forKey:@"unifiedCloseButtonOver"];
		[aCoder encodeObject:unifiedCloseDirtyButton forKey:@"unifiedCloseDirtyButton"];
		[aCoder encodeObject:unifiedCloseDirtyButtonDown forKey:@"unifiedCloseDirtyButtonDown"];
		[aCoder encodeObject:unifiedCloseDirtyButtonOver forKey:@"unifiedCloseDirtyButtonOver"];
		[aCoder encodeObject:_addTabButtonImage forKey:@"addTabButtonImage"];
		[aCoder encodeObject:_addTabButtonPressedImage forKey:@"addTabButtonPressedImage"];
		[aCoder encodeObject:_addTabButtonRolloverImage forKey:@"addTabButtonRolloverImage"];
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	// self = [super initWithCoder:aDecoder];
	//if (self) {
	if([aDecoder allowsKeyedCoding]) {
		unifiedCloseButton = [[aDecoder decodeObjectForKey:@"unifiedCloseButton"] retain];
		unifiedCloseButtonDown = [[aDecoder decodeObjectForKey:@"unifiedCloseButtonDown"] retain];
		unifiedCloseButtonOver = [[aDecoder decodeObjectForKey:@"unifiedCloseButtonOver"] retain];
		unifiedCloseDirtyButton = [[aDecoder decodeObjectForKey:@"unifiedCloseDirtyButton"] retain];
		unifiedCloseDirtyButtonDown = [[aDecoder decodeObjectForKey:@"unifiedCloseDirtyButtonDown"] retain];
		unifiedCloseDirtyButtonOver = [[aDecoder decodeObjectForKey:@"unifiedCloseDirtyButtonOver"] retain];
		_addTabButtonImage = [[aDecoder decodeObjectForKey:@"addTabButtonImage"] retain];
		_addTabButtonPressedImage = [[aDecoder decodeObjectForKey:@"addTabButtonPressedImage"] retain];
		_addTabButtonRolloverImage = [[aDecoder decodeObjectForKey:@"addTabButtonRolloverImage"] retain];
	}
	//}
	return self;
}

@end
