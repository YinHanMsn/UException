//
//  NCUException.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//


#import "NCUException.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#pragma mark - NCUException

@interface NCUException()
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) NSArray<NSNumber *> *callStackReturnAddresses;
@property (nonatomic, copy) NSArray<NSString *> *callStackSymbols;
@property (nonatomic, retain) NSData *screenshot;
@property (nonatomic, copy) NSString* appInfo;
@property (nonatomic, copy) NSString* exceptionString;
@property (nonatomic, assign) BOOL isSignal;
@end

@implementation NCUException

-(instancetype)init {
    self = [super init];
    if (self) {
        self.time = [NSDate date];
    }
    return self;
}

-(NSString*)appInfo {
    if (!_appInfo) {
        NSMutableString *str = [NSMutableString string];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *project = [infoDictionary objectForKey:@"CFBundleExecutable"]; //获取项目名称
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; //获取项目版本号
        NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"]; //获取项目构造版本号
        [str appendFormat:@"%@[%@_%@]", project, version, build];
        _appInfo = str;
    }
    return _appInfo;
}

-(NSString *)exceptionString {
    if (!_exceptionString) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *time = [dateFormatter stringFromDate:self.time];
        NSMutableString *string = [[NSMutableString alloc] init];
        [string appendFormat:@"%@ %@ ", time, self.appInfo];
        [string appendFormat:@"*** Terminating app due to uncaught exception '%@', reason: '%@'\n", self.name, self.reason];
        [string appendString:@"*** First throw call stack:\n(\n"];
        for (NSUInteger i = 0; i<self.callStackSymbols.count; i++) {
            [string appendFormat:@"\t%@\n", self.callStackSymbols[i]];
        }
        [string appendString:@")\n"];
        _exceptionString = [string copy];
    }
    return _exceptionString;
}

//-(NSString *)description {
//    return [NSString stringWithFormat:@"%@\n%@", self.exceptionString, self.screenshot.description];
//}

@end

#pragma mark - _NCUException

@interface _NCUException :NSObject
@property (nonatomic, copy) BOOL(^ueHandler)(NCUException* ue);
@property (nonatomic, assign) BOOL screenshot;
-(void)exception:(NCUException*) exception;

@end

static _NCUException* _uException = nil;

void _NCUExceptionHandler(NSException *exception) {
    NCUException * ue = [[NCUException alloc] init];
    ue.callStackSymbols = [exception callStackSymbols];
    ue.callStackReturnAddresses = [exception callStackReturnAddresses];
    ue.reason = [exception reason];
    ue.name = [exception name];
    ue.userInfo = [exception userInfo];
    [_uException performSelectorOnMainThread:@selector(exception:) withObject:ue waitUntilDone:YES];
}

//当前处理的异常个数
volatile int32_t UncaughtExceptionCount = 0;
//最大能够处理的异常个数
volatile int32_t UncaughtExceptionMaximum = 10;
//SIGABRT 程序由于abort()函数调用发生的程序中止信号
//SIGILL 程序由于非法指令产生的程序中止信号
//SIGSEGV 程序由于无效内存的引用导致的程序中止信号
//SIGFPE 程序由于浮点数异常导致的程序中止信号
//SIGBUS 程序由于内存地址未对齐导致的程序中止信号
//SIGPIPE 程序通过端口发送消息失败导致的程序中止信号

void _NSSExceptionHandler(int signal) {
    //获取堆栈
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    long i;
    NSMutableArray *callStackSymbols = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        [callStackSymbols addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    #pragma clang diagnostic pop
    
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:@"signal"];
    
    NSString *name = @"SignalException";
    switch (signal) {
        case SIGABRT:
            name = [name stringByAppendingFormat:@"_%@", @"SIGABRT"];
            break;
        case SIGILL:
            name = [name stringByAppendingFormat:@"_%@", @"SIGILL"];
            break;
        case SIGSEGV:
            name = [name stringByAppendingFormat:@"_%@", @"SIGSEGV"];
            break;
        case SIGFPE:
            name = [name stringByAppendingFormat:@"_%@", @"SIGFPE"];
            break;
        case SIGBUS:
            name = [name stringByAppendingFormat:@"_%@", @"SIGBUS"];
            break;
        case SIGPIPE:
            name = [name stringByAppendingFormat:@"_%@", @"SIGPIPE"];
            break;
        case SIGHUP:
            name = [name stringByAppendingFormat:@"_%@", @"SIGHUP"];
            break;
        case SIGINT:
            name = [name stringByAppendingFormat:@"_%@", @"SIGINT"];
            break;
        case SIGQUIT:
            name = [name stringByAppendingFormat:@"_%@", @"SIGQUIT"];
            break;
        default:
            break;
    }
    
    NCUException * ue = [[NCUException alloc] init];
    ue.callStackSymbols = [callStackSymbols copy];
    ue.reason = [NSString stringWithFormat:@"Signal %d was raised.",signal];
    ue.name = name;
    ue.userInfo = userInfo;
    ue.isSignal = YES;
    
    [_uException performSelectorOnMainThread:@selector(exception:) withObject:ue waitUntilDone:YES];
}

@implementation _NCUException

#if NCUException_enabled
+(void)load {
    [super load];
    [_NCUException shareInstance];
}
#endif

+(instancetype) shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _uException = [[super allocWithZone:NULL] init] ;
        [self regUncaughtExceptionHandler];
    }) ;
    return _uException ;
}

+(id) allocWithZone:(struct _NSZone *)zone {
    return [_NCUException shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone {
    return [_NCUException shareInstance];
}


+ (void)regUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler (&_NCUExceptionHandler);

    signal(SIGABRT, _NSSExceptionHandler);
    signal(SIGILL, _NSSExceptionHandler);
    signal(SIGSEGV, _NSSExceptionHandler);
    signal(SIGFPE, _NSSExceptionHandler);
    signal(SIGBUS, _NSSExceptionHandler);
    signal(SIGPIPE, _NSSExceptionHandler);
    
    signal(SIGHUP, _NSSExceptionHandler);
    signal(SIGINT, _NSSExceptionHandler);
    signal(SIGQUIT, _NSSExceptionHandler);
    


}

+ (void)unRegUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    signal(SIGHUP, SIG_DFL);
    signal(SIGINT, SIG_DFL);
    signal(SIGQUIT, SIG_DFL);
}

-(void)exception:(NCUException*)exception {
    [_NCUException unRegUncaughtExceptionHandler];
    
    if (self.screenshot) {
        exception.screenshot = [self dataWithScreenshotInPNGFormat];//截屏
    }
    
    BOOL b = YES;
    if (self.ueHandler) {
        b = self.ueHandler(exception);
    }
    if (b) {
        printf("%s", [exception.exceptionString UTF8String]);
    }

}


-(void)exceptionHandler:(BOOL(^)(NCUException* ue))handler {
    self.ueHandler = handler;
}

- (NSData *)dataWithScreenshotInPNGFormat {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    }else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}


@end

#pragma mark - Handler or Config
void uExceptionHandler(BOOL(^handler)(NCUException* ue)) {
    [_uException exceptionHandler:handler];
}
void uExceptionScreenshot(BOOL screenshot) {
    _uException.screenshot = screenshot;
}


