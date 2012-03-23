#ifdef __OBJC__

    #ifdef __DEBUG__
        #ifndef DEBUG
            #define DEBUG
        #endif
    #endif

    #if DEBUG
        #ifndef DEBUG
            #define DEBUG
        #endif
    #endif

    #ifdef DEBUG
        #ifndef DLOG
            #define DLOG
        #endif
    #endif

    #ifdef DLOG
        #import <Foundation/Foundation.h>

#pragma mark - Object Logging Methods

        /*void DLog(NSString *format, ...) {
            va_list ap;
            va_start (ap, format);
            if (![format hasSuffix: @"\n"])
                format = [format stringByAppendingString: @"\n"];
            NSString *body =  [[NSString alloc] initWithFormat:format arguments:ap];
            va_end (ap);
            fprintf(stderr,"%s",[body UTF8String]);
            [body release];
        }*/

        #ifndef DLOG_PREFIX
            #define DLOG_PREFIX DL
        #endif

        #define Q_(x) #x
        #define Q(x) Q_(x)

#pragma mark - NSLogger shortcuts

        #define LOG_NETWORK(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"network",level,__VA_ARGS__)
        #define LOG_GENERAL(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"general",level,__VA_ARGS__)
        #define LOG_GRAPHICS(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"graphics",level,__VA_ARGS__)

// TODO: Consolidate all of these NSLog methods to eliminate boilerplate/repeat info
        #define DLog(format, ...)       NSLog(@"%s:%@;", Q(DLOG_PREFIX), [NSString stringWithFormat:[@" " stringByAppendingString:format], ## __VA_ARGS__ ])
        #define DLogObject(Object)      NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #Object , Object)
        #define DLogNSObject(NSObject)  NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #NSObject , NSObject)
        #define DLogClass(Class)        NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #Class, [NSString stringWithUTF8String:(class_getName(Class))])
        #define DLogSEL(SEL)            NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #SEL, NSStringFromSelector(SEL))
        #define DLogRetain(Object)      NSLog(@"%s:%s;RET:%i;%s:%d", Q(DLOG_PREFIX), #Object, [Object retainCount], __PRETTY_FUNCTION__, __LINE__)
        #define DLogCFRetain(CFObject)  NSLog(@"%s:%s;RET:%i;", Q(DLOG_PREFIX), #CFObject, CFGetRetainCount(CFObject))
        #define DLogINT(int)            NSLog(@"%s:%s;%i;", Q(DLOG_PREFIX), #int, int)
        #define DLogFLOAT(float)        NSLog(@"%s:%s;%f;", Q(DLOG_PREFIX), #float, float)
        #define DLogBOOL(BOOL)          NSLog(@"%s:%s;%s;", Q(DLOG_PREFIX), #BOOL, (BOOL ? "YES" : "NO"))
        #define DLogTRUE(BOOL)          if (BOOL) { DLogBOOL(BOOL);}do{}while(0)
        #define DLogUIView(Object)      UILogViewHierarchy(Object)
        #define DLogFunc()              NSLog(@"%s:%s;%d;", Q(DLOG_PREFIX), __PRETTY_FUNCTION__, __LINE__)

        #if IPHONE_ONLY
            #define DLogCGRect(CGRect)  NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #CGRect, NSStringFromCGRect(CGRect))
            #define DLogCGSize(CGSize)  NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #CGSize, NSStringFromCGSize(CGSize))
            #define DLogCGPoint(CGPoint)    NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #CGPoint, NSStringFromCGPoint(CGPoint))
        #elif MAC_ONLY
            #define DLogCGRect(CGRect)  NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #CGRect, NSStringFromRect(NSRectFromCGRect(CGRect)))
            #define DLogNSRect(NSRect)  NSLog(@"%s:%s;%@;", Q(DLOG_PREFIX), #NSRect, NSStringFromRect(NSRect))
        #endif

#pragma mark - Time Logging

        #define DStart(key)             NSDate *__dTime ## key = [NSDate date]
        #define DEnd(key)               NSTimeInterval __dInterval ## key = [__dTime ## key timeIntervalSinceNow]; \
                                        NSLog(@"%s:%s;%f;", Q(DLOG_PREFIX), #key, -(__dInterval ## key))
        #define DEndMod(key, mod)       NSTimeInterval __dInterval ## key = [__dTime ## key timeIntervalSinceNow]; \
                                        NSLog(@"%s:%s;%f;", Q(DLOG_PREFIX), #key, (-(__dInterval ## key))-mod)
#pragma mark - Thread Logging

        #define DLogThread()            NSLog(@"%s:%s;%d:main=%s;", Q(DLOG_PREFIX), __PRETTY_FUNCTION__, __LINE__,([NSThread isMainThread]?"YES":"NO"))

#pragma mark - Class Method Logging

        #define DLogvoid()
        #define DLogid(Object)      NSLog(@"%s:%s:%@;", Q(DLOG_PREFIX), #Object , Object)
        #define DLogdouble(double)  NSLog(@"%s:%s:%f;", Q(DLOG_PREFIX), #double, double)
        #define DLogint(Int)        NSLog(@"%s:%s:%i;", Q(DLOG_PREFIX), #Int, Int)
        #define DLoglong(Long)      NSLog(@"%s:%s:%ld;", Q(DLOG_PREFIX), #Long, (long)Long)
        #define DLoglonglong(Long)  NSLog(@"%s:%s:%lld;", Q(DLOG_PREFIX), #Long, Long)

        #define DLogMethodv0(selName) \
            - (void)selName { \
                DLogFunc(); \
                [super selName]; \
            }
        #define DLogMethod0(rettype, selName) \
            - (rettype)selName { \
                DLogFunc(); \
                rettype retVar = [super selName]; \
                DLog ## rettype(retVar); \
                return retVar; \
            }
        #define DLogMethodv1(selName, selArgType) \
            - (void)selName:(selArgType)fp8 { \
                DLogFunc(); \
                DLog ## selArgType(fp8); \
                [super selName:fp8]; \
            }
        #define DLogMethod1(rettype, selName1, selArgType1) \
            - (rettype)selName1:(selArgType1)fp8 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                rettype retVar = [super selName1:fp8]; \
                DLog ## rettype(retVar); \
                return retVar; \
            }
        #define DLogMethodv2(selName1, selArgType1, selName2, selArgType2) \
            - (void)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                [super selName1:fp8 selName2:fp16]; \
            }
        #define DLogMethod2(rettype, selName1, selArgType1, selName2, selArgType2) \
            - (rettype)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                rettype retVar = [super selName1:fp8 selName2:fp16]; \
                DLog ## rettype(retVar); \
                return retVar; \
            }
        #define DLogMethodv3(selName1, selArgType1, selName2, selArgType2, selName3, selArgType3) \
            - (void)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 selName3:(selArgType3)fp32 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                DLog ## selArgType3(fp32); \
                [super selName1:fp8 selName2:fp16 selName3:fp32]; \
            }
        #define DLogMethod3(rettype, selName1, selArgType1, selName2, selArgType2, selName3, selArgType3) \
            - (rettype)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 selName3:(selArgType3)fp32 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                DLog ## selArgType3(fp32); \
                rettype retVar = [super selName1:fp8 selName2:fp16 selName3:fp32]; \
                DLog ## rettype(retVar); \
                return retVar; \
            }
        #define DLogMethodv4(selName1, selArgType1, selName2, selArgType2, selName3, selArgType3, selName4, selArgType4) \
            - (void)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 selName3:(selArgType3)fp32 selName4:(selArgType4)fp64 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                DLog ## selArgType3(fp32); \
                DLog ## selArgType4(fp64); \
                [super selName1:fp8 selName2:fp16 selName3:fp32 selName4:fp64]; \
            }
        #define DLogMethod4(rettype, selName1, selArgType1, selName2, selArgType2, selName3, selArgType3, selName4, selArgType4) \
            - (rettype)selName1:(selArgType1)fp8 selName2:(selArgType2)fp16 selName3:(selArgType3)fp32 selName4:(selArgType4)fp64 { \
                DLogFunc(); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType1(fp8); \
                DLog ## selArgType2(fp16); \
                DLog ## selArgType3(fp32); \
                DLog ## selArgType4(fp64); \
                rettype retVar = [super selName1:fp8 selName2:fp16 selName3:fp32 selName4:fp64]; \
                DLog ## rettype(retVar); \
                return retVar; \
            }
    #else

        #define LOG_NETWORK(...)    do{}while(0)
        #define LOG_GENERAL(...)    do{}while(0)
        #define LOG_GRAPHICS(...)   do{}while(0)

        #define DLog(format, ...) do{}while(0)
        #define DLogObject(object) do{}while(0)
        #define DLogClass(object) do{}while(0)
        #define DLogSEL(object) do{}while(0) 
        #define DLogRetain(object) do{}while(0)
        #define DLogCFRetain(object) do{}while(0)
        #define DLogINT(object) do{}while(0)
        #define DLogBOOL(object) do{}while(0)
        #define DLogUIView(object) do{}while(0)
        #define DLogCGRect(object) do{}while(0)
        #define DLogFunc() do{}while(0)
        #define DLogMethod0(object, object1) do{}while(0)
        #define DLogMethod1(object, object1) do{}while(0)
        #define DLogMethod2(object, object1, object2) do{}while(0)
        #define DLogMethod3(object, object1, object2, object3) do{}while(0)
        #define DLogvoid() do{}while(0)
        #define DLogid() do{}while(0)
        #define DStart(obj) do{}while(0)
        #define DEnd(obj) do{}while(0)
        #define DEndMod(obj, object) do{}while(0)
        #define DLogThread() do{}while(0)
        #define DLoglong() do{}while(0)
        #define DLogNSRect() do{}while(0)
    #endif
#endif