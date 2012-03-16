//
//  GKHotKeyView.m
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/3/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//

#import "GKHotKeyView.h"

@implementation GKHotKeyView

@synthesize hotkey = _hotkey;

#pragma mark - NSObject life cycle

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _hotkey = nil;
        _hasFocus = NO;
        
        [GKHotKeyCenter sharedCenter];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(playPauseKeyNotification) name:MediaKeyPlayPauseNotification object:nil];
        [center addObserver:self selector:@selector(nextKeyNotification) name:MediaKeyNextNotification object:nil];
        [center addObserver:self selector:@selector(previousKeyNotification) name:MediaKeyPreviousNotification object:nil];
        
        [self addObserver:self forKeyPath:@"hotkey" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame hotkey:(GKHotKey *)aHotkey {
    if ((self = [self initWithFrame:frame])) {
        _hotkey = aHotkey;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"hotkey"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 *  Watch change of "hotkey" property to redraw
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hotkey"]) {
        [self becomeFirstResponder];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playPauseKeyNotification {
    /*_playKey = YES;
    [self performKeyEquivalent:nil];
    _playKey = NO;*/
}

- (void)nextKeyNotification {
    /*_nextKey = YES;
    [self performKeyEquivalent:nil];
    _nextKey = NO;*/
}

- (void)previousKeyNotification {
    //DLogFunc();
    /*_backKey = YES;
    [self performKeyEquivalent:nil];
    _backKey = NO;*/
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    // Set view background as white
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    // Draw border around view
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 0.5, 0.5)];
    [[NSColor colorWithDeviceWhite:0.780 alpha:1.000] set];
    [border setLineWidth:1.0];
    [border stroke];
    
    // Draw Text
    NSString *mString = @"⇧⌃⌥⌘ ";
    // should be: NSString *mString = [GKHotKey modifierStringRepresentation:@"shift", @"ctrl", @"alt", @"cmd", nil];
    // ctrl => control, ctl
    // alt  => option, opt
    // cmd  => command
    
    if(_hotkey)
        mString = [mString stringByAppendingString:[_hotkey characterStringRepresentation]];
    
    CGFloat fontSize = [self fontSizeForAreaSize:[self bounds].size withString:mString]; // optimal => 22.0f
    NSFont *textFont = [NSFont fontWithName:@"Helvetica" size:fontSize];
    NSColor *activeTextColor = [NSColor colorWithCalibratedHue:0.775 saturation:1.000 brightness:0.438 alpha:1.000];
    
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys: 
                          textFont, NSFontAttributeName, 
                          activeTextColor, NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:mString attributes:attr];
    
    //DLogObject(NSStringFromRect([self bounds]));
    //DLogFLOAT(fontSize);
    
    NSColor *disabledTextColor = [NSColor colorWithCalibratedWhite:0.902 alpha:1.000];
    if(!_hotkey.hasShiftKey)
        [attrString addAttribute:NSForegroundColorAttributeName value:disabledTextColor range:NSMakeRange(0, 1)];
    if(!_hotkey.hasControlKey)
        [attrString addAttribute:NSForegroundColorAttributeName value:disabledTextColor range:NSMakeRange(1, 1)];
    if(!_hotkey.hasAlternateKey)
        [attrString addAttribute:NSForegroundColorAttributeName value:disabledTextColor range:NSMakeRange(2, 1)];
    if(!_hotkey.hasCommandKey)
        [attrString addAttribute:NSForegroundColorAttributeName value:disabledTextColor range:NSMakeRange(3, 1)];
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);	
    CGContextSetTextPosition(context, 8.0, round(self.bounds.size.height * 0.28125)); 
    CTLineDraw(line, context);
    
    CFRelease(line);

    // Draw Focus Ring (when focused)
    if (_hasFocus || self == [[self window] firstResponder]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 0.0, 0.0)] fill];
        [NSGraphicsContext restoreGraphicsState];
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    [self setNeedsDisplay:YES];
    if(self == [[self window] firstResponder]) {
        [self mouseUp:nil];
    }
    return YES;
}

- (BOOL)resignFirstResponder {
    [self setNeedsDisplay:YES];
    _hasFocus = NO;
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self lockFocus];
    _hasFocus = YES;
}

/*- (BOOL)isOpaque {
    return YES;
}*/

/*- (void)flagsChanged:(NSEvent *)theEvent {
    //NSLog(@"fC:%@", theEvent);
    //NSLog(@"fC2:%@", [theEvent modifierFlags]);
}*/

/*- (void)keyDown:(NSEvent *)theEvent {
    if([GKHotKey validEvent:theEvent]) {
        GKHotKey *aHotkey = [[GKHotKey alloc] initHotKeyWithEvent:theEvent];
        self.hotkey = aHotkey;
        [aHotkey release];
        [self display];
    }
}*/

- (CGFloat)fontSizeForAreaSize:(NSSize)areaSize withString:(NSString *)stringToSize {
    NSFont *displayFont = nil;
    NSSize stringSize = NSZeroSize;
    NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];

    if (areaSize.width == 0.0 && areaSize.height == 0.0)
        return 0.0;

    NSUInteger fontLoop = 0;
    for (fontLoop = 1; fontLoop <= 10000; fontLoop++) {
        NSFont *textFont = [NSFont fontWithName:@"Helvetica" size:fontLoop];
        displayFont = [[NSFontManager sharedFontManager] convertWeight:YES ofFont:textFont];
        [fontAttributes setObject:displayFont forKey:NSFontAttributeName];
        stringSize = [stringToSize sizeWithAttributes:fontAttributes];

        if (stringSize.width > areaSize.width)
            break;
        if (stringSize.height > areaSize.height)
            break;
    }
    
    return (CGFloat)fontLoop - 5.0;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    NSLog(@" sjfkla %@", [theEvent charactersIgnoringModifiers]);
    if(_hasFocus && [GKHotKey validEvent:theEvent]) {
        self.hotkey = [[GKHotKey alloc] initHotKeyWithEvent:theEvent];
        return YES;
    } else
        return [super performKeyEquivalent:theEvent];
}

- (NSFocusRingType)focusRingType {
    return NSFocusRingTypeExterior;
}


@end
