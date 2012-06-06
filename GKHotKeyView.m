//
//  GKHotKeyView.m
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/3/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//

#if MAC_ONLY

#import "GKHotKeyView.h"

NSString * const GKHotKeyViewChangeNotification = @"GKHotKeyViewChangeNotification";

@implementation GKHotKeyView

@synthesize hotkey = _hotkey;

#pragma mark - NSObject life cycle

- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, 237, 34)];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _hotkey = nil;
        _hasFocus = NO;
        
        [self addObserver:self forKeyPath:@"hotkey" options:NSKeyValueObservingOptionNew context:NULL];
        [NSNtf addObserver:self selector:@selector(viewKeyChange:) name:GKHotKeyViewChangeNotification object:nil];
        [NSNtf addObserver:self selector:@selector(keyDownNotification:) name:KeyboardKeyDownNotification object:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame hotkey:(GKHotKey *)aHotkey {
    if ((self = [self initWithFrame:frame])) {
        _hotkey = aHotkey;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hotkey"]) {
        [self setNeedsDisplay:YES];
        [NSNtf postNotificationName:GKHotKeyViewChangeNotification object:self];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/*
 * TODO: Make optionally used, for class support w/o HKCenter
 * Needed for media key support in the hotkeyview
 */
- (void)keyDownNotification:(NSNotification*)notif {
    GKHotKey *key = [notif.userInfo objectForKey:@"key"];
    if ([key isEqual:self.hotkey] && !_hasFocus) {
        self.hotkey = nil;
        return;
    }
    if(!_hasFocus)
        return;
    self.hotkey = key;
    // TODO: add debugging nslog stmts
    //DLogFunc();
    //DLogObject(self.hotkey);
}

- (void)viewKeyChange:(NSNotification*)notif {
    if (notif.object == self)
        return;
    if ([[notif.object hotkey] isEqual:self.hotkey]) {
        self.hotkey = nil;
    }
    // TODO: add debugging nslog stmts
    //DLogObject(notif.object);
    //DLogObject(self);
    /*if ([ isEqual:self.hotkey] && ![notif.object isEqual:self]) {
        _hotkey = nil;
    }*/
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"hotkey"];
    [NSNtf removeObserver:self];
}

#pragma mark - NSObject event behavior

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    [[GKHotKeyCenter sharedCenter] setEnabled:NO];
    [self lockFocus];
    _hasFocus = YES;
    [self setNeedsDisplay:YES];
    //if(self == [[self window] firstResponder]) {
    //    [self mouseUp:nil];
    //}
    return YES;
}

- (BOOL)resignFirstResponder {
    //[self unlockFocus];

    _hasFocus = NO;
    [self setNeedsDisplay:YES];
    [[GKHotKeyCenter sharedCenter] setEnabled:YES];
    return YES;
}

/*- (void)mouseUp:(NSEvent *)theEvent {

}*/

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

#define NX_KEYTYPE_DELETE 51
#define NX_KEYTYPE_ESCAPE 53

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    // TODO: Add debug nslog stmts
    //DLogFunc();
    //DLogObject(theEvent);
    unsigned short code = theEvent.keyCode;
    if(_hasFocus && (code == NX_KEYTYPE_DELETE || code == NX_KEYTYPE_ESCAPE)) {
        self.hotkey = nil;
        return YES;
    } else if(_hasFocus && [GKHotKey validEvent:theEvent]) {
        self.hotkey = [[GKHotKey alloc] initWithEvent:theEvent];
        //DLogFunc();
        //DLogObject(self.hotkey);
        return YES;
    } else
        return [super performKeyEquivalent:theEvent];
}

#pragma mark - NSView appearance

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    // Set view background as white
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    // Draw border around view
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 0.5, 0.5)];
    [[NSColor colorWithDeviceWhite:0.78 alpha:1] set];
    [border setLineWidth:1];
    [border stroke];
    
    // Setup Text and Attributes
    NSString *hkString = _hotkey ? _hotkey.symbolicStringWithModifiers : @"⇧⌃⌥⌘ ";
    
    CGFloat fontSize = [self fontSizeForAreaSize:self.bounds.size withString:hkString]; // optimal => 22.0f
    NSFont *textFont = [NSFont fontWithName:@"Helvetica" size:fontSize]; //[NSFont systemFontOfSize:fontSize]; //
    NSColor *liveColor = [NSColor colorWithCalibratedHue:0.775 saturation:1 brightness:0.438 alpha:1];
    
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys: 
                          textFont, NSFontAttributeName, 
                          liveColor, NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString *nsStr = [[NSMutableAttributedString alloc] initWithString:hkString attributes:attr];
    CFMutableAttributedStringRef cfStr = (__bridge CFMutableAttributedStringRef)nsStr;
    NSUInteger strLen = [nsStr length];
    
    //DLogObject(NSStringFromRect([self bounds]));
    //DLogFLOAT(fontSize);
    
    // Set modifier keys gray if inactive
    NSColor *deadColor = [NSColor colorWithCalibratedWhite:0.902 alpha:1];
    if(!_hotkey.hasShiftKey)
        [nsStr addAttribute:NSForegroundColorAttributeName value:deadColor range:NSMakeRange(0, 1)];
    if(!_hotkey.hasControlKey)
        [nsStr addAttribute:NSForegroundColorAttributeName value:deadColor range:NSMakeRange(1, 1)];
    if(!_hotkey.hasAlternateKey)
        [nsStr addAttribute:NSForegroundColorAttributeName value:deadColor range:NSMakeRange(2, 1)];
    if(!_hotkey.hasCommandKey)
        [nsStr addAttribute:NSForegroundColorAttributeName value:deadColor range:NSMakeRange(3, 1)];
    
    // Media Symbols
    
    if(_hotkey.hasMediaKey) {
        CTFontRef uniCharFont = (__bridge CTFontRef)[NSFont fontWithName:@"Webdings" size:round(fontSize*.869)];
        CTFontRef pauseFont = (__bridge CTFontRef)[NSFont fontWithName:@"Webdings" size:round(fontSize*1.27)];
        
        int uniCharLen = _hotkey.isPlayKey ? 1 : 2;
        CFRange uniCharRange = strLen > 5 ? CFRangeMake(5, uniCharLen) : CFRangeMake(0, 0);
        CFRange pauseRange = _hotkey.isPlayKey && strLen > 5 ? CFRangeMake(6, 1) : CFRangeMake(0, 0);
        CFAttributedStringSetAttribute(cfStr, uniCharRange, kCTFontAttributeName, uniCharFont);
        CFAttributedStringSetAttribute(cfStr, pauseRange, kCTFontAttributeName, pauseFont);
        
        int nextBackAdj = _hotkey.isNextKey ? round(fontSize*-.043478) : round(fontSize*-.2174);
        int kernAdjVal = _hotkey.isPlayKey ? round(fontSize*-.30435) : nextBackAdj;
        CFNumberRef uniCharKernAdj = (__bridge CFNumberRef)[NSNumber numberWithInt:kernAdjVal];
        CFAttributedStringSetAttribute(cfStr, uniCharRange, kCTKernAttributeName, uniCharKernAdj);
    }
    
    // Draw text
    CTLineRef line = CTLineCreateWithAttributedString(cfStr);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);	
    CGContextSetTextPosition(context, 8, round(self.bounds.size.height * .27)); 
    CTLineDraw(line, context);
    
    CFRelease(line);
    
    // Draw Focus Ring (when focused)
    if (_hasFocus || self == [[self window] firstResponder]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 0, 0)] fill];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (CGFloat)fontSizeForAreaSize:(NSSize)areaSize withString:(NSString *)stringToSize {
    NSFont *displayFont = nil;
    NSSize stringSize = NSZeroSize;
    NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
    
    if (areaSize.width == 0 && areaSize.height == 0)
        return 0;
    
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
    
    return (CGFloat)fontLoop - 5;
}

- (NSFocusRingType)focusRingType {
    return NSFocusRingTypeExterior;
}

@end

#endif
