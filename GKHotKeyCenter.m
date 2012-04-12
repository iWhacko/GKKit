//
//  GKHotKeyController.m
//
//  Modified by Gaurav Khanna on 8/17/10.
//  SOURCE: http://github.com/sweetfm/SweetFM/blob/master/Source/HMediaKeys.m
//  SOURCE: http://stackoverflow.com/questions/2969110/cgeventtapcreate-breaks-down-mysteriously-with-key-down-events
//
//
//  Permission is hereby granted, free of charge, to any person 
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, 
//  merge, publish, distribute, sublicense, and/or sell copies of 
//  the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be 
//  included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
//  ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if MAC_ONLY

#import "GKHotKeyCenter.h"

NSString * const KeyboardKeyDownNotification = @"KeyboardKeyDownNotification";
NSString * const KeyboardKeyUpNotification = @"KeyboardKeyUpNotification";

#define NX_KEYSTATE_UP      0x0A
#define NX_KEYSTATE_DOWN    0x0B

@interface GKHotKeyCenter (PRIVATE)

- (CFMachPortRef)eventPort;
- (NSMutableArray*)handlers;

@end

CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if(type == kCGEventTapDisabledByTimeout) {
        CGEventTapEnable([[GKHotKeyCenter sharedCenter] eventPort], TRUE);
        return event;
    }
    
    if (![[GKHotKeyCenter sharedCenter] isEnabled])
        return event;

    GKHotKey *key;
    BOOL state;
    BOOL handled = NO;
    
    if (type == kCGEventKeyUp || type == kCGEventKeyDown) {
        CGEventFlags flags = CGEventGetFlags(event);
        int64_t keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        
        DLogObject(key);
        
        BOOL sh = (flags & kCGEventFlagMaskShift) != 0;
        BOOL co = (flags & kCGEventFlagMaskControl) != 0;
        BOOL cm = (flags & kCGEventFlagMaskCommand) != 0;
        BOOL al = (flags & kCGEventFlagMaskAlternate) != 0;
        
        if (!sh && !co && !cm && !al)
            return event;
        
        key = [[GKHotKey alloc] initWithKeyCode:keycode modifierFlags:1];
        key.shiftKey = sh;
        key.controlKey = co;
        key.commandKey = cm;
        key.alternateKey = al;
        
        DLogFunc();
        
        //key.shiftKey = flags & kCGEventFlagMaskShift;
        //key.controlKey = flags & kCGEventFlagMaskControl;
        //key.commandKey = flags & kCGEventFlagMaskCommand;
        //key.alternateKey = flags & kCGEventFlagMaskAlternate;
        //DLogObject(key);
        
        //DLogBOOL([key isPlayKey]);
        //DLogBOOL([key isNextKey]);
        //DLogBOOL([key hasShiftKey]);
        //DLogBOOL([key hasAlternateKey]);
        //DLogBOOL([key hasControlKey]);
        //DLogBOOL([key hasCommandKey]);
        
        state = type == kCGEventKeyUp;
    } else if(type == NX_SYSDEFINED) {
        NSEvent *nsEvent = [NSEvent eventWithCGEvent:event];
        
        if(nsEvent.subtype != 8)
            return event;
        
        // CGEventGetFlags
        // CGEventKeyboardGetUnicodeString
        // CGEventGetDoubleValueField(event, kCGMouseEventSubtype);
        
        int data = [nsEvent data1];
        int keyFlags = (data & 0xFFFF);
        int keyCode = (data & 0xFFFF0000) >> 16;
        int keyState = (keyFlags & 0xFF00) >> 8;
        BOOL keyIsRepeat = (keyFlags & 0x1) > 0;
        
        if(keyIsRepeat) 
            return event;
        
        // filter useless events
        if (keyState != NX_KEYSTATE_DOWN && keyState != NX_KEYSTATE_UP)
            return event;
        
        key = [[GKHotKey alloc] initWithKeyCode:keyCode];
        state = keyState == NX_KEYSTATE_UP;
        
    } else
        return event;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:key, @"key", nil];
    [NSNtf postNotificationName:KeyboardKeyDownNotification object:(__bridge id)refcon userInfo:dict];
    
    // activate all handlers registered
    for (id func in [[GKHotKeyCenter sharedCenter] handlers]) {
        BOOL (^block)(GKHotKey*, int) = func;
        if (block(key, state)) {
            // event was handled
            handled = YES;
        }
    }
    return handled ? NULL : event;
}

@implementation GKHotKeyCenter

@synthesize enabled;

MAKE_SINGLETON(GKHotKeyCenter, sharedCenter)

+ (void)registerHandler:(GKHotKeyBlock)block {
    GKHotKeyCenter *center = [GKHotKeyCenter sharedCenter];
    if (![[center handlers] containsObject:block]) {
        [[center handlers] addObject:block];
    }
}

+ (void)unregisterHandler:(GKHotKeyBlock)block {
    GKHotKeyCenter *center = [GKHotKeyCenter sharedCenter];
    for (id func in [center handlers]) {
        if ([func isEqual:block]) {
            [[center handlers] removeObject:block];
            return;
        }
    }
}

- (id)init {
    if(self = [super init]) {
        self.enabled = YES;
        CFRunLoopRef runLoop;
        CFRunLoopSourceRef runLoopSource;
        
        _handlers = [[NSMutableArray alloc] initWithCapacity:1];

        _eventPort = CGEventTapCreate(kCGSessionEventTap,
                                      kCGHeadInsertEventTap,
                                      kCGEventTapOptionDefault,
                                      CGEventMaskBit(NX_SYSDEFINED) 
                                      | CGEventMaskBit(kCGEventKeyDown)
                                      | CGEventMaskBit(kCGEventKeyUp),
                                      tapEventCallback,
                                      (__bridge void *)(self));
        
        if(_eventPort  == NULL) {
            NSLog(@"[%s:%d] ERROCGEventTapRefort could not be created", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, _eventPort, 0);

        if(runLoopSource == NULL) {
            NSLog(@"[%s:%d] ERROR: CFRunLoopSourceRef could not be created", __PRETTY_FUNCTION__, __LINE__);
//            return nil;   
        }

        runLoop = CFRunLoopGetCurrent();

        if(runLoop == NULL) {
            NSLog(@"[%s:%d] ERROR: Could not get the current threads CFRunLoopRef", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }

        CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
    }
    return self;
}

- (CFMachPortRef)eventPort {
    return _eventPort;
}

 - (NSMutableArray*)handlers {
     return _handlers;
 }
     
- (void)dealloc {
    CFRelease(_eventPort);
}

@end

#endif
