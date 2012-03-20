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

#pragma mark - Class Convenience Methods
+ (BOOL)validEvent:(NSEvent *)theEvent;

//TODO: NSString *mString = [GKHotKey modifierStringRepresentation:@"shift", @"ctrl", @"alt", @"cmd", nil];
// ctrl => control, ctl
// alt  => option, opt
// cmd  => command
// 

//TODO: + (NSString*)symbolicStringWithModifiers:(BOOL)modifiers, ...;
//+ (NSString*)symbolicStringWithModifierStrings:(NSString*)modifiers, ...;

+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode;
+ (NSString*)symbolicStringWithKeyCode:(unsigned short)keyCode mediaKey:(BOOL)mediaKey;

#pragma mark - NSObject life cycle
//TODO: - (id)initWithKey:(NSInteger)key;
//- (id)initWithKey:(NSInteger)key modifiers:(BOOL)modifiers, ...;
//- (id)initWithKey:(NSInteger)key modifierNames:(NSString*)modifiers, ...;

- (id)initWithEvent:(NSEvent*)theEvent;

- (id)initWithKeyCode:(unsigned short)keyCode;
- (id)initWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

//TODO: - (id)initWithTrigger:(NSString*)character modifierFlags:(NSUInteger)flags;

#pragma mark - Character Key Detection
@property NSInteger key;
//TODO: @property (readonly) NSString *keyTrigger;

@property (nonatomic) unsigned short keyCode;
@property (nonatomic, strong) NSString *keyTrigger;

#pragma mark - Modifier Key Detection
//TODO: @property (readonly) NSArray *modifiers;
@property (getter=hasShiftKey) BOOL shiftKey;
@property (getter=hasCommandKey) BOOL commandKey;
@property (getter=hasControlKey) BOOL controlKey;
@property (getter=hasAlternateKey) BOOL alternateKey;

//TODO: - (void)setModifiers:(BOOL)modifiers, ...;
//- (void)setModifierNames:(NSString*)modifiers, ...;

#pragma mark - Media Key Detection
@property (readonly, getter=isPlayKey) BOOL playKey;
@property (readonly, getter=isNextKey) BOOL nextKey;
@property (readonly, getter=isBackKey) BOOL backKey;

@property (readonly, getter=hasMediaKey) BOOL mediaKey;

#pragma mark - HotKey String Representation
- (NSString*)symbolicString;
- (NSString*)symbolicStringWithModifiers;

#pragma mark - Modifier Flags Manipulation
@property (nonatomic) NSUInteger modifierFlags;
- (void)setModifierFlag:(NSUInteger)keyMask value:(BOOL)value;


@end