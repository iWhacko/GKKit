#ifdef __OBJC__
    #import <Foundation/Foundation.h>
    #import <objc/message.h>
    #import <objc/runtime.h>

    // TODO: Test & Fix
    //#define NSObjectMessageSendSuper(obj, msg, ...) \
        ^{ \
            return (id)objc_msgSendSuper(&(struct objc_super){obj, class_getSuperclass([obj class])}, msg, ## __VA_ARGS__); \
        }()
    //#define NSObjectMessageSendSuper(obj, msg, ...) \
        return (id)objc_msgSendSuper(&(struct objc_super){obj, class_getSuperclass([obj class])}, msg, ## __VA_ARGS__);

    //#define NSObjectMessageSendSuperSuper(obj, msg, ...) \
        ^{ \
            return (id)objc_msgSendSuper(&(struct objc_super){obj, class_getSuperclass(class_getSuperclass([obj class]))}, @selector(msg), ## __VA_ARGS__); \
        }()

    #define NSDef [NSUserDefaults standardUserDefaults]
    #define $(class) objc_getClass(#class)
    #define OBJC_ARC __has_feature(objc_arc)
    /*#if OBJC_ARC
        #define retain strong
        #define assign weak
    #else
        #define strong retain
        #define weak assign
    #endif*/

    #if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
        #define MAC_ONLY 1
    #elif TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        #define IPHONE_ONLY 1
    #endif

    #ifdef MAC_ONLY
        #define GKApp [NSApplication sharedApplication]
        #define GKAppDelegate (id)[[NSApplication sharedApplication] delegate]
        #define GKApp [NSApplication sharedApplication]
        #define GKView NSView
        #define GKRect NSRect
        #define GKWindow NSWindow

    #elif IPHONE_ONLY
        #import <QuartzCore/QuartzCore.h>
        #define GKApp [UIApplication sharedApplication]
        #define GKAppDelegate [UIApp delegate]
        #define GKView UIView
        #define GKRect CGRect
        #define GKWindow UIWindow

        #define UIViewFrameChangeValue( view, key, value) \
            CGRect view ## Frame = view.frame; \
            view ## Frame.key = value; \
            [view setFrame:view ## Frame]

        #define CGRectRoundFrameValues( frame) \
            CGRectMake( roundf(frame.origin.x), roundf(frame.origin.y), roundf(frame.size.width), roundf(frame.size.height))

        #define UIViewFrameRoundValues( view) \
            [view setFrame:CGRectRoundFrameValues( view.frame)]

        #define UIApplicationDirectory \
            ^{ \
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); \
                return (id)( ([paths count] > 0) ? [paths objectAtIndex:0] : nil ); \
            }

        #define UIInterfaceOrientationIsValidAndNotUpsideDown(orientation) \
            (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)

    #endif
#endif