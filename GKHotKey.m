//
//  GKHotKey.m
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/8/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//

#import "GKHotKey.h"

@implementation GKHotKey

@synthesize keyTrigger;
@synthesize keyCode;
@synthesize modifierFlags;

#pragma mark - Class Data Methods

+ (BOOL)validEvent:(NSEvent *)theEvent {
    return ((theEvent.modifierFlags & NSControlKeyMask) != 0 
         || (theEvent.modifierFlags & NSCommandKeyMask) != 0  
         || (theEvent.modifierFlags & NSAlternateKeyMask) != 0);
    /* TODO: Support Media Key Event
    || theEvent.keyCode == NX_KEYTYPE_PLAY
    || theEvent.keyCode == NX_KEYTYPE_NEXT
    || theEvent.keyCode == NX_KEYTYPE_REWIND
    && theEvent.modifierFlags == 0*/
}

// => http://stackoverflow.com/questions/2345196/objective-c-passing-around-nil-terminated-argument-lists
/*+ (NSShift*)stringRepresentationWithModifiers:(NSString*)modifiers, ... {
    
}*/

+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode {
    return [GKHotKey symbolicStringWithKeyCode:keyCode mediaKey:FALSE];
}

+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode mediaKey:(BOOL)mediaKey {
    #define NX_KEYTYPE_GRAVE 50
    #define NX_KEYTYPE_4 21
    #define NX_KEYTYPE_5 23
    #define NX_KEYTYPE_6 22
    #define NX_KEYTYPE_7 26
    #define NX_KEYTYPE_8 28
    #define NX_KEYTYPE_9 25
    #define NX_KEYTYPE_0 29
    #define NX_KEYTYPE_DASH 27
    #define NX_KEYTYPE_EQUAL 24
    #define NX_KEYTYPE_LEFT_BRACKET 33
    #define NX_KEYTYPE_RIGHT_BRACKET 30
    #define NX_KEYTYPE_BACKSLASH 42
    #define NX_KEYTYPE_SEMICOLON 41
    #define NX_KEYTYPE_APOSTROPHE 39
    #define NX_KEYTYPE_COMMA 43
    #define NX_KEYTYPE_PERIOD 47
    #define NX_KEYTYPE_FORWARDSLASH 44
    #define NX_KEYTYPE_SPACE 49
    #define NX_KEYTYPE_LEFT 123
    #define NX_KEYTYPE_RIGHT 124
    #define NX_KEYTYPE_DOWN 125
    #define NX_KEYTYPE_UP 126
    
    switch (keyCode) {
        // Media Keys share keycodes with 1,2,3
        case NX_KEYTYPE_PLAY:
            return mediaKey ? @"▶" : @"1"; ///@"▶"; //@"";
        case NX_KEYTYPE_FAST:
            return mediaKey ? @"▶▶" : @"2"; //@"";
        case NX_KEYTYPE_REWIND:
            return mediaKey ? @"◀◀" : @"3"; //@"";
        case NX_KEYTYPE_GRAVE:
            return @"`";
        case NX_KEYTYPE_4:
            return @"4";
        case NX_KEYTYPE_5:
            return @"5";
        case NX_KEYTYPE_6:
            return @"6";
        case NX_KEYTYPE_7:
            return @"7";
        case NX_KEYTYPE_8:
            return @"8";
        case NX_KEYTYPE_9:
            return @"9";
        case NX_KEYTYPE_0:
            return @"0";
        case NX_KEYTYPE_DASH:
            return @"-";
        case NX_KEYTYPE_EQUAL:
            return @"=";
        case NX_KEYTYPE_LEFT_BRACKET:
            return @"[";
        case NX_KEYTYPE_RIGHT_BRACKET:
            return @"]";
        case NX_KEYTYPE_BACKSLASH:
            return @"\\";
        case NX_KEYTYPE_SEMICOLON:
            return @";";
        case NX_KEYTYPE_APOSTROPHE:
            return @"'";
        case NX_KEYTYPE_COMMA:
            return @",";
        case NX_KEYTYPE_PERIOD:
            return @".";
        case NX_KEYTYPE_FORWARDSLASH:
            return @"/";
        case NX_KEYTYPE_SPACE:
            return @"Space";
        case NX_KEYTYPE_LEFT:
            return @"←";
        case NX_KEYTYPE_RIGHT:
            return @"→";
        case NX_KEYTYPE_DOWN:
        case NX_DOWN_ARROW_KEY:
            return @"↓";
        case NX_KEYTYPE_UP:
        case NX_UP_ARROW_KEY:
            return @"↑";
        default: {
            return @"";
            CGEventRef keyEvent = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, true);
            
            UniCharCount maxStrLength = 4;
            UniCharCount actualStrLength;
            //UniChar str[maxStrLength];
            UniChar *strBuf = CFAllocatorAllocate(NULL, maxStrLength * sizeof(UniChar), 0);
            
            CGEventKeyboardGetUnicodeString(keyEvent, maxStrLength, &actualStrLength, strBuf); 
            
            //DLoglong(actualStrLength);
            //DLogSTR(str);
            
            CFStringRef cfStr = CFStringCreateWithCharacters(NULL, strBuf, actualStrLength);
            
            NSString *nsStr = [(__bridge NSString*)cfStr capitalizedString];
            
            //DLogObject(nsStr);
            
            CFRelease(keyEvent);
            CFRelease(cfStr);
            
            return nsStr;
        }
    }
}

#pragma mark - Class Instantiation Convenience Methods

+ (id)hotKeyWithKey:(NSNumber*)num {
    return [[GKHotKey alloc] initWithKeyCode:[num unsignedShortValue] modifierFlags:0];
}

#pragma mark - NSObject life cycle

- (id)init {
    if ((self = [super init])) {
        self.modifierFlags = 0;
        self.keyTrigger = nil;
        self.keyCode = 0;
    }
    return self;
}

- (id)initWithEvent:(NSEvent *)theEvent {
    if ((self = [super init])) {
        self.keyCode = theEvent.keyCode;
        self.modifierFlags = theEvent.modifierFlags;
        if ([theEvent type] == NSKeyUp || [theEvent type] == NSKeyDown)
            self.keyTrigger = theEvent.charactersIgnoringModifiers;
    }
    return self;
}

- (id)initWithKeyCode:(unsigned short)code {
    if ((self = [super init])) {
        self.keyCode = code;
    }
    return self;
}

- (id)initWithKeyCode:(unsigned short)code modifierFlags:(NSUInteger)flags {
    if ((self = [super init])) {
        self.keyCode = code;
        self.modifierFlags = flags;
    }
    return self;
}
/* TODO:
- (id)initWithTrigger:(NSString *)aCharacter modifierFlags:(NSUInteger)flags {
    if ((self = [super init])) {
        self.modifierFlags = flags;
        self.keyTrigger = aCharacter;
    }
    return self;
}*/

#pragma mark - NSObject serialization

- (void)encodeWithCoder:(NSCoder *)coder { 
    [coder encodeObject:self.key forKey:@"key"];      
    [coder encodeObject:self.modifierKey forKey:@"modifierKey"];         
} 

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        self.key = [coder decodeObjectForKey:@"key"];
        self.modifierKey = [coder decodeObjectForKey:@"modifierKey"];
    }
    return self; 
}

#pragma mark - NSObject subclassing

- (NSUInteger)hash {
    NSString *hash = [NSString stringWithFormat:@"%@%i%i%i%i", 
                      self.key, self.hasShiftKey, self.hasControlKey, 
                      self.hasAlternateKey, self.hasCommandKey, nil];
    return [[[[NSNumberFormatter alloc] init] numberFromString:hash] unsignedIntegerValue];
}

- (BOOL)isEqual:(GKHotKey*)object {
    return ([object.key isEqualToNumber:self.key] 
            && object.hasShiftKey == self.hasShiftKey
            && object.hasControlKey == self.hasControlKey
            && object.hasAlternateKey == self.hasAlternateKey
            && object.hasCommandKey == self.hasCommandKey);
}

#pragma mark - NSObject String Representations

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; key:%@(%@); mods:%i%@(%@%@%@%@)", 
            [super description], self.key, self.keyTrigger,
            [NSNumber numberWithUnsignedInteger:self.modifierFlags],
            (self.hasShiftKey ? @"⇧" : @""), 
            (self.hasControlKey ? @"⌃" : @""), 
            (self.hasAlternateKey ? @"⌥" : @""), 
            (self.hasCommandKey ? @"⌘" : @""), nil];
}

- (NSString*)symbolicString {
    //TODO: implement class method
    //return [GKHotKey stringRepresentationWithKeyCode:self.keyCode mediaKey:self.hasMediaKey];
    
    NSString *symbols = [GKHotKey symbolicStringWithKeyCode:self.keyCode mediaKey:self.hasMediaKey];
    NSString *keySym = self.keyTrigger.capitalizedString;
    if (symbols.length == 0) 
        return (keySym ? keySym : @"");
    return (symbols ? symbols : @"");
}

- (NSString*)symbolicStringWithModifiers {
    return [@"⇧⌃⌥⌘ " stringByAppendingString:self.symbolicString];
}

#pragma mark - Character Key Manipulation

- (NSNumber*)key {
    return [NSNumber numberWithUnsignedShort:self.keyCode];
}

- (void)setKey:(NSNumber*)keyNum {
    self.keyCode = [keyNum unsignedShortValue];
}

#pragma mark - Modifier Flags Manipulation

/* TODO: Convenience for modifier iteration...probably not neccesary
 
 - (NSArray*)modifiers {
    NSNumber *shiftNum = [NSNumber alloc] initWith
    
    
    NSArray *tmp = [NSArray arrayWithObjects:
}*/

- (BOOL)hasShiftKey {
    return (self.modifierFlags & NSShiftKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasControlKey {
    return (self.modifierFlags & NSControlKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasCommandKey {
    return (self.modifierFlags & NSCommandKeyMask) == 0 ? NO : YES;
}

- (BOOL)hasAlternateKey {
    return (self.modifierFlags & NSAlternateKeyMask) == 0 ? NO : YES;
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

- (NSNumber*)modifierKey {
    return [NSNumber numberWithUnsignedInteger:self.modifierFlags];
}

- (void)setModifierKey:(NSNumber*)num {
    self.modifierFlags = [num unsignedIntegerValue];
}

- (void)setModifierFlag:(NSUInteger)keyMask value:(BOOL)val {
    NSUInteger new = self.modifierFlags;
    if (val)
        new |= (keyMask);
    else
        new &= ~(keyMask);
    self.modifierFlags = new;
}

#pragma mark - Media Key Detection

- (BOOL)isPlayKey {
    return self.keyCode == NX_KEYTYPE_PLAY;
}

- (BOOL)isNextKey {
    return self.keyCode == NX_KEYTYPE_FAST;
}

- (BOOL)isBackKey {
    return self.keyCode == NX_KEYTYPE_REWIND;
}

- (BOOL)hasMediaKey {
    return self.keyCode == NX_KEYTYPE_PLAY 
           || self.keyCode == NX_KEYTYPE_FAST 
           || self.keyCode == NX_KEYTYPE_REWIND;
}

@end