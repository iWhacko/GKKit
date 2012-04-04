//
//  NSEvent+Additions.m
//  Pandorium
//
//  Created by Gaurav Khanna on 8/17/10.
//

#if MAC_ONLY

#import "NSEvent+GKAdditions.h"

@implementation NSEvent (Additions)

+ (id)mouseEventWithType:(NSEventType)type point:(NSPoint)point {
    return [NSEvent mouseEventWithType:type
                              location:point
                         modifierFlags:0
                             timestamp:0
                          windowNumber:[[[NSApp delegate] window] windowNumber]
                               context:0
                           eventNumber:0
                            clickCount:1
                              pressure:0];
    /* Not neccesary after all! Keeping for reference                      
    return [NSEvent mouseEventWithType:type
                              location:point
                         modifierFlags:( type == NSLeftMouseUp ? 0x100 : 0x100 )
                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                          windowNumber:[[NSApp keyWindow] windowNumber]
                               context:[[NSApp currentEvent] context]
                           eventNumber:([[NSApp currentEvent] eventNumber] + 1) 
                            clickCount:1
                              pressure:( type == NSLeftMouseDown ? 1 : 0 )];*/
}

+ (id)keyEventWithType:(NSEventType)type keyCode:(unsigned short)keyCode { 
    return [NSEvent keyEventWithType:type 
                            location:NSMakePoint(490, 540)
                       modifierFlags:0x100
                           timestamp:[NSDate timeIntervalSinceReferenceDate]
                        windowNumber:[[[NSApp delegate] window] windowNumber] 
                             context:0
                          characters:@" "
         charactersIgnoringModifiers:@" "
                           isARepeat:FALSE 
                             keyCode:keyCode];
}

+ (id)keyEventWithType:(NSEventType)type keyCode:(unsigned short)keyCode modifiers:(NSUInteger)mod {
    return [NSEvent keyEventWithType:type 
                            location:NSMakePoint(490, 540)
                       modifierFlags:NSShiftKeyMask
                           timestamp:[NSDate timeIntervalSinceReferenceDate]
                        windowNumber:[[[NSApp delegate] window] windowNumber] 
                             context:0
                          characters:@" "
         charactersIgnoringModifiers:@" "
                           isARepeat:FALSE 
                             keyCode:keyCode];
}

@end

#endif
