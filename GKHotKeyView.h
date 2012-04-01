//
//  GKHotKeyView.h
//
//  Created by Gaurav Khanna on 11/3/10.
//  Default dimensions @ 237x34
//

#import <Cocoa/Cocoa.h>
#import "GKHotKey.h"
#import "GKHotKeyCenter.h"

extern NSString * const GKHotKeyViewChangeNotification;

@class GKHotKey, GKHotKeyCenter;

@interface GKHotKeyView : NSView {
@private
    GKHotKey *_hotkey;
    BOOL _hasFocus;
}

@property (nonatomic, strong) GKHotKey *hotkey;

- (id)initWithFrame:(NSRect)frame hotkey:(GKHotKey *)hotkey;

@end