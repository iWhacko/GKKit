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

#import "GKHotKeyCenter.h"

NSString * const KeyboardKeyDownNotification = @"KeyboardKeyDownNotification";
NSString * const MediaKeyPlayPauseNotification = @"MediaKeyPlayPauseNotification";
NSString * const MediaKeyNextNotification = @"MediaKeyNextNotification";
NSString * const MediaKeyPreviousNotification = @"MediaKeyPreviousNotification";

#define NX_KEYSTATE_UP      0x0A
#define NX_KEYSTATE_DOWN    0x0B

CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if(type == kCGEventTapDisabledByTimeout)
        CGEventTapEnable([[GKHotKeyCenter sharedCenter] eventPort], TRUE);
    
    if(type != NX_SYSDEFINED) 
        return event;
    
	NSEvent *nsEvent = [NSEvent eventWithCGEvent:event];
    
    if(nsEvent.subtype != 8) 
        return event;
    
    int data = [nsEvent data1];
    //DLogINT([nsEvent keyCode]);
    int keyCode = (data & 0xFFFF0000) >> 16;
    DLogINT(keyCode);
    int keyFlags = (data & 0xFFFF);
    int keyState = (keyFlags & 0xFF00) >> 8;
    BOOL keyIsRepeat = (keyFlags & 0x1) > 0;
    
    if(keyIsRepeat) 
        return event;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    switch (keyCode) {
        case NX_KEYTYPE_PLAY:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyPlayPauseNotification object:(__bridge id)refcon];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
            break;
        case NX_KEYTYPE_FAST:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyNextNotification object:(__bridge id)refcon];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
            break;
        case NX_KEYTYPE_REWIND:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyPreviousNotification object:(__bridge id)refcon];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
            break;
        default:
            if(keyState == NX_KEYSTATE_DOWN) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:keyCode], @"keycode", nil];
                [center postNotificationName:KeyboardKeyDownNotification object:(__bridge id)refcon userInfo:dict];
            }
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
            break;
    }
    return event;
}

@implementation GKHotKeyCenter

MAKE_SINGLETON(GKHotKeyCenter, sharedCenter)

- (id)init {
    if(self = [super init]) {
        CFRunLoopRef runLoop;
        CFRunLoopSourceRef runLoopSource;

        _eventPort = CGEventTapCreate(kCGSessionEventTap,
                                      kCGHeadInsertEventTap,
                                      kCGEventTapOptionDefault,
                                      CGEventMaskBit(NX_SYSDEFINED),
                                      tapEventCallback,
                                      (__bridge void *)(self));

        if(_eventPort == NULL) {
            NSLog(@"[%s:%d] ERROR: CGEventTapRef could not be created", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, _eventPort, 0);

        if(runLoopSource == NULL) {
            NSLog(@"[%s:%d] ERROR: CFRunLoopSourceRef could not be created", __PRETTY_FUNCTION__, __LINE__);
            return nil;
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

- (void)dealloc {
    CFRelease(_eventPort);
}

@end
