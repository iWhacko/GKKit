//
//  GKHotKey.m
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/8/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//

#import "GKHotKey.h"


@implementation GKHotKey

@synthesize character = _character;
@synthesize shiftKey, controlKey, commandKey, alternateKey;

+ (BOOL)validEvent:(NSEvent *)theEvent {
    return ([theEvent modifierFlags] & NSAlternateKeyMask) != 0 
        || ([theEvent modifierFlags] & NSCommandKeyMask) != 0  
        || ([theEvent modifierFlags] & NSControlKeyMask) != 0;
}

#pragma mark - NSObject life cycle

- (id)init {
    if ((self = [super init])) {
        _modifierFlags = 0;
        _character = @"";
    }
    return self;
}

- (id)initHotKeyWithEvent:(NSEvent *)theEvent {
    if ((self = [super init])) {
        _modifierFlags = [theEvent modifierFlags];
        self.character = [theEvent charactersIgnoringModifiers];
    }
    return self;
}

- (id)initHotKeyWithCharacter:(NSString *)aCharacter modifierFlags:(NSUInteger)flags {
    if ((self = [super init])) {
        _modifierFlags = flags;
        self.character = aCharacter;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Modifier Keys

- (NSUInteger)modifierFlags {
    return _modifierFlags;
}

- (void)setModifierFlag:(NSUInteger)keyMask value:(BOOL)val {
    NSUInteger new = _modifierFlags;
    if (val)
        new |= (keyMask);
    else
        new &= ~(keyMask);
    _modifierFlags = new;
}

- (BOOL)hasShiftKey {
    return (_modifierFlags & NSShiftKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasControlKey {
    return (_modifierFlags & NSControlKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasCommandKey {
    return (_modifierFlags & NSCommandKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasAlternateKey {
    return (_modifierFlags & NSAlternateKeyMask) == 0 ? NO : YES;
}

- (void)setShiftKey:(BOOL)key {
    [self setModifierFlag:NSShiftKeyMask value:key];
}

- (void)setControlKey:(BOOL)key {
    [self setModifierFlag:NSControlKeyMask value:key];
}

- (void)setCommandKey:(BOOL)key {
    [self setModifierFlag:NSCommandKeyMask value:key];
}

- (void)setAlternateKey:(BOOL)key {
    [self setModifierFlag:NSAlternateKeyMask value:key];
}

#pragma mark - HotKey String Representation

- (id)characterStringRepresentation {
    NSLog(@"%@", _character);
    if([_character isEqualToString:@" "])
        return @"Space";
    if([_character isEqualToString:@""])
        return @"→";
    if([_character isEqualToString:@""])
        return @"←";
    if([_character isEqualToString:@""])
        return @"↑";
    if([_character isEqualToString:@""])
        return @"↓";
    // Shift invokes top-key symbol 
    // (return the bottom symbol) ...unneccesary cruft
    /*if([character isEqualToString:@">"])
        return @".";
    if([character isEqualToString:@"<"])
        return @",";
    if([character isEqualToString:@"?"])
        return @"/";
    if([character isEqualToString:@":"])
        return @";";
    if([character isEqualToString:@"\""])
        return @"'";
    if([character isEqualToString:@"{"])
        return @"[";
    if([character isEqualToString:@"}"])
        return @"]";
    if([character isEqualToString:@"|"])
        return @"\\";
    if([character isEqualToString:@"_"])
        return @"-";
    if([character isEqualToString:@"+"])
        return @"=";
    if([character isEqualToString:@")"])
        return @"0";
    if([character isEqualToString:@"("])
        return @"9";
    if([character isEqualToString:@"*"])
        return @"8";
    if([character isEqualToString:@"&"])
        return @"7";
    if([character isEqualToString:@"^"])
        return @"6";
    if([character isEqualToString:@"%"])
        return @"5";
    if([character isEqualToString:@"$"])
        return @"4";
    if([character isEqualToString:@"#"])
        return @"3";
    if([character isEqualToString:@"@"])
        return @"2";
    if([character isEqualToString:@"!"])
        return @"1";
    if([character isEqualToString:@"~"])
        return @"`";*/
    if(![_character isEqualToString:@""])
        return [_character capitalizedString];
    return @"";
}


@end