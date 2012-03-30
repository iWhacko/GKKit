//
//  NSEvent+Additions.h
//  Pandorium
//
//  Created by Gaurav Khanna on 8/17/10.
//

@interface NSEvent (Additions)

+ (id)mouseEventWithType:(NSEventType)type point:(NSPoint)point;
+ (id)keyEventWithType:(NSEventType)type keyCode:(unsigned short)keyCode;
+ (id)keyEventWithType:(NSEventType)type keyCode:(unsigned short)keyCode modifiers:(NSUInteger)mod;

@end
