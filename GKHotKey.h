//
//  GKHotKey.h
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/8/10.
//  Copyright (c) 2010 GK Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GKHotKey : NSObject {
@private
    NSString *_character;
    NSUInteger _modifierFlags;
}

@property (nonatomic, strong) NSString *character;
@property (getter=hasShiftKey) BOOL shiftKey;
@property (getter=hasCommandKey) BOOL commandKey;
@property (getter=hasControlKey) BOOL controlKey;
@property (getter=hasAlternateKey) BOOL alternateKey;

+ (BOOL)validEvent:(NSEvent *)theEvent;

- (id)initHotKeyWithEvent:(NSEvent *)theEvent;
- (id)initHotKeyWithCharacter:(NSString *)character modifierFlags:(NSUInteger)flags;

- (NSUInteger)modifierFlags;
- (void)setModifierFlag:(NSUInteger)keyMask value:(BOOL)value;

- (NSString*)characterStringRepresentation;


@end
