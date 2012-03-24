//
//  View+GKAdditions.h
//  GKKit
//
//  Created by Gaurav Khanna on 7/14/10.
//

#import <Foundation/Foundation.h>
#import "common.h"

#ifdef MAC_ONLY
#define GKView NSView

@interface NSView (GKAdditions)

+ (void)dumpView:(NSView *)view prefix:(NSString *)prefix indent:(NSString *)indent;
- (void)dump;
- (NSString *)hierarchalDescription;
- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade;

@end

#elif IPHONE_ONLY
#define GKView UIView

@interface UIView (GKAdditions)

+ (void)dumpView:(UIView *)view prefix:(NSString *)prefix indent:(NSString *)indent;
- (void)dump;
- (NSString *)hierarchalDescription;

@end

@interface UIImageView (GKAdditions)

- (id)initWithView:(UIView *)view origin:(CGPoint)origin;

@end

#endif

