//
//  GKHotKey.h
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/8/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//
//  Symbol Reference: http://macbiblioblog.blogspot.com/2005/05/special-key-symbols.html
//  APPL KB Reference: http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/KEYBOARD.TXT
//
//  Usage: A View with initial value of "⌘⌥+J"
//
//      GKHotKeyView *ahkView = [[GKHotKey alloc] initWithTrigger:@"j" modifierNames:@"cmd", @"alt", nil];

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <IOKit/hidsystem/ev_keymap.h>

@interface GKHotKey : NSObject 

#pragma mark - Class Data Methods
+ (BOOL)validEvent:(NSEvent *)theEvent;

// TODO: NSString *mString = [GKHotKey modifierStringRepresentation:@"shift", @"ctrl", @"alt", @"cmd", nil];
// ctrl => control, ctl
// alt  => option, opt
// cmd  => command
// 

// TODO: + (NSString*)symbolicStringWithModifiers:(BOOL)modifiers, ...;
//+ (NSString*)symbolicStringWithModifierStrings:(NSString*)modifiers, ...;

+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode;
+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode mediaKey:(BOOL)mediaKey;

#pragma mark - Class Instantiation Convenience Methods
+ (id)hotKeyWithKey:(NSNumber*)num;
// + (id)hotKeyWithKey:(NSNumber*)num modifiers:(BOOL)modifiers, ...;
// + (id)hotKeyWithKey:(NSNumber*)num modifierStrings:(NSString*)modifiers, ...;

#pragma mark - NSObject life cycle
// TODO: - (id)initWithKey:(NSNumber*)key;
//- (id)initWithKey:(NSNumber*)key modifiers:(BOOL)modifiers, ...;
//- (id)initWithKey:(NSNumber*)key modifierNames:(NSString*)modifiers, ...;

- (id)initWithEvent:(NSEvent*)theEvent;

- (id)initWithKeyCode:(unsigned short)keyCode;
- (id)initWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

// TODO: - (id)initWithTrigger:(NSString*)character modifierFlags:(NSUInteger)flags;

#pragma mark - HotKey String Representation
- (NSString*)symbolicString;
- (NSString*)symbolicStringWithModifiers;

#pragma mark - Character Key Detection
@property (weak) NSNumber *key;
// TODO: @property (readonly) NSString *keyTrigger;

// TODO: consider renaming keyCode => rawCode
@property (nonatomic) unsigned short keyCode;
@property (nonatomic, strong) NSString *keyTrigger;

#pragma mark - Modifier Flags Manipulation
@property (getter=hasShiftKey) BOOL shiftKey;
@property (getter=hasCommandKey) BOOL commandKey;
@property (getter=hasControlKey) BOOL controlKey;
@property (getter=hasAlternateKey) BOOL alternateKey;

// TODO: @property (readonly) NSArray *modifiers;
// TODO: - (void)setModifiers:(BOOL)modifiers, ...;
//- (void)setModifierNames:(NSString*)modifiers, ...;

@property (weak) NSNumber *modifierKey;
@property (nonatomic) NSUInteger modifierFlags;

- (void)setModifierFlag:(NSUInteger)keyMask value:(BOOL)value;

#pragma mark - Media Key Detection
@property (readonly, getter=isPlayKey) BOOL playKey;
@property (readonly, getter=isNextKey) BOOL nextKey;
@property (readonly, getter=isBackKey) BOOL backKey;

@property (readonly, getter=hasMediaKey) BOOL mediaKey;

@end