//
//  WebView+Additions.h
//  Pandorium
//
//  Created by Gaurav Khanna on 8/16/10.
//

#import <WebKit/WebKit.h>
#import "NSObject+GKAdditions.h"
#import "NSEvent+GKAdditions.h"
#import "View+GKAdditions.h"

//#define TEST

@interface WebView (Additions)

- (void)mouseClickAtLocation:(NSPoint)point;

- (void)keyClickWithKeyCode:(unsigned short)keyCode;
- (void)keyClickWithKeyCode:(unsigned short)keyCode modifier:(unsigned short)mod;

@end

@interface WebHTMLView : NSControl {
    
}

- (NSView *)_hitViewForEvent:(NSEvent *)event;

@end

#ifdef TEST

@interface WebHTMLView (Additions)

- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;

@end
#endif