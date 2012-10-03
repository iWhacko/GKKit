//
//  View+GKAdditions.m
//  GKKit
//
//  Created by Gaurav Khanna on 7/14/10.
//

#import "View+GKAdditions.h"

@implementation GKView (GKAdditions)

+ (void)dumpView:(GKView *)view prefix:(NSString *)prefix indent:(NSString *)indent {
    NSLog(@"%@%@%@",(indent?indent:@""),(prefix?prefix:@""),[view hierarchalDescription]);
    int i = 0;
    for(GKView *subview in view.subviews) {
        NSString *newIndent = [NSString stringWithFormat:@"  %@", indent];
        NSString *newPrefix = [NSString stringWithFormat:@"%@%d:", newIndent, i++];
        [GKView dumpView:subview prefix:newPrefix indent:newIndent];
    }
}

- (NSString *)hierarchalDescription {
    NSString *selfClass = NSStringFromClass([self class]);
    if([[selfClass substringToIndex:2] isEqualToString:@"UI"] || [[selfClass substringToIndex:2] isEqualToString:@"NS"]) {
        return [self description];
    } else {
        NSMutableString *desc = [NSMutableString stringWithString:selfClass];
        Class cl = [self superclass];
        while((![[NSStringFromClass(cl) substringToIndex:2] isEqualToString:@"UI"]) \
              && (![[NSStringFromClass(cl) substringToIndex:2] isEqualToString:@"NS"]) \
              && (cl = [cl superclass])) {
            [desc appendFormat:@":%@",NSStringFromClass(cl),nil];
        }
        [desc appendString:[[self description] substringFromIndex:[selfClass length]+1]];
        return [NSString stringWithFormat:@"<%@>",desc,nil];
    }
}

- (void)dump {
    [GKView dumpView:self prefix:@"" indent:@""];
}

#ifdef MAC_ONLY

/**
 Hides or unhides an NSView, making it fade in or our of existance.
 @param hidden YES to hide, NO to show
 @param fade if NO, just setHidden normally.
 */

- (void)setHidden:(BOOL)hidden withFade:(BOOL)fade delegate:(id<NSAnimationDelegate>)delegate {
    if(!fade) {
        // The easy way out.  Nothing to do here...
        [self setHidden:hidden];
    } else {
        // FIXME: It would be better to check for the availability of NSViewAnimation at runtime intead
        // of at compile time.  I'm lazy, and I make two builds anyways, so I do it at compile. -ZSB
        if(!hidden) {
            // If we're unhiding, make sure we queue an unhide before the animation
            [self setHidden:NO];
        }
        NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
        animDict[NSViewAnimationTargetKey] = self;
        animDict[NSViewAnimationEffectKey] = (hidden ? NSViewAnimationFadeOutEffect : NSViewAnimationFadeInEffect);
        
        NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:@[animDict]];
        [anim setDuration:0.5];
        [anim setAnimationBlockingMode:NSAnimationNonblocking];
        [anim setAnimationCurve:NSAnimationEaseInOut];
        [anim setDelegate:delegate];
        [anim startAnimation];
    }
    
}

- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade {
    [self setHidden:hidden withFade:fade delegate:nil];
}

#endif

@end

#ifdef IPHONE_ONLY

@implementation UIImageView (GKAdditions)

- (id)initWithView:(UIView *)view origin:(CGPoint)origin {
    if((self = [super init])) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [self setFrame:CGRectMake(origin.x, origin.y, image.size.width, image.size.height)];
        [self setImage:image];
    }
    return self;
}

@end

#endif