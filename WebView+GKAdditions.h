//
//  WebView+Additions.h
//  Pandorium
//
//  Created by Gaurav Khanna on 8/16/10.
//

#import <WebKit/WebKit.h>
#import "NSObject+GKAdditions.h"
#import "NSEvent+Additions.h"
#import "GKView+GKAdditions.h"

//#define TEST

@interface WebView (Additions)

- (void)keyClickWithKeyCode:(unsigned short)keyCode;
- (void)mouseClickAtLocation:(NSPoint)point;

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