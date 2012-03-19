//
//  GKHotKeyView.h
//  GKHotKeyView
//
//  Created by Gaurav Khanna on 11/3/10.
//
//  Default dimensions @ 237x32
//
//  Symbol Reference: http://macbiblioblog.blogspot.com/2005/05/special-key-symbols.html
//  APPL KB Reference: http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/KEYBOARD.TXT
//
//  Usage: A View with initial value of "⌘⌥+J"
//
//      GKHotKeyView *ahkView = [[GKHotKeyView alloc] initHotKeyViewWithCharacter:@"j" modifierSrings:@"cmd", @"alt", nil];

#import <Cocoa/Cocoa.h>
#import "GKHotKey.h"

@class GKHotKey, GKHotKeyCenter;

@interface GKHotKeyView : NSView {
@private
    GKHotKey *_hotkey;
    BOOL _hasFocus;
}

@property (nonatomic, strong) GKHotKey *hotkey;

- (id)initWithFrame:(NSRect)frame hotkey:(GKHotKey *)hotkey;

@end