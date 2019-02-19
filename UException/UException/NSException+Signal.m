//
//  NSException+Signal.m
//  UException
//
//  Created by YLCHUN on 2017/2/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSException+Signal.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>
#import <execinfo.h>

@interface NSException (Signal)
@property (nonatomic, copy) NSArray<NSString *> *se_callStackSymbols;
@end

@implementation NSException (Signal)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(callStackSymbols);
        SEL swizzledSelector = @selector(s_callStackSymbols);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

-(NSArray<NSString *> *)s_callStackSymbols {
    if (self.se_callStackSymbols) {
        return [self se_callStackSymbols];
    }else{
        return [self s_callStackSymbols];
    }
}

-(NSArray<NSString *> *)se_callStackSymbols {
    return objc_getAssociatedObject(self, @selector(se_callStackSymbols));
}

-(void)setSe_callStackSymbols:(NSArray<NSString *> *)se_callStackSymbols {
    objc_setAssociatedObject(self, @selector(se_callStackSymbols), se_callStackSymbols, OBJC_ASSOCIATION_COPY);
}

//-(void)callStackSymbolsClear {
//    NSMutableArray * arr = [self.callStackSymbols mutableCopy];
//    for (long i = 0; i<arr.count; i++) {
//        if ([arr[i] containsString:@"<redacted> +"]) {//信息过滤
//            [arr removeObjectAtIndex:i];
//            i--;
//        }
//    }
//    self.se_callStackSymbols = arr;
//}
//
//-(void)callStackSymbolsSlide {
//    NSArray * slideArr = [ASLRSlide slides];
//    NSMutableArray * arr = [self.callStackSymbols mutableCopy];
//    for (long i = 0; i<arr.count; i++) {
//        NSString *imageName = [arr[i] componentsSeparatedByString:@"0x"].firstObject;
//        for (ASLRSlide * s in slideArr) {
//            if ([imageName containsString:s.imageName]) {
//                arr[i] = [NSString stringWithFormat:@"%@\t(slide: %@)", arr[i], s.slideStr];
//                break;
//            }
//        }
//    }
//    self.se_callStackSymbols = arr;
//}

@end


typedef void se_NSSignalExceptionHandler(int signal);

static NSUncaughtExceptionHandler * se_uncaughtExceptionHandler = NULL;
static NSUncaughtExceptionHandler * se_allExceptionHandler = NULL;

//最大能够处理的异常个数
volatile int32_t UncaughtExceptionMaximum = 10;
//SIGABRT 程序由于abort()函数调用发生的程序中止信号，通常异常是由于某个对象接收到未实现的消息引起的。 或者，用简单的话说，在某个对象上调用了不存在的方法。
//SIGILL 程序由于非法指令产生的程序中止信号
//SIGSEGV 程序由于无效内存的引用导致的程序中止信号
//SIGFPE 程序由于浮点数异常导致的程序中止信号
//SIGBUS 程序由于内存地址未对齐导致的程序中止信号
//SIGPIPE 程序通过端口发送消息失败导致的程序中止信号


//SIGHUP 在用户终端连接(正常或非正常)结束时发出, 通常是在终端的控制进程结束时, 通知同一session内的各个作业, 这时它们与控制终端不再关联
//SIGINT 程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程
//SIGQUIT 和SIGINT类似, 但由QUIT字符(通常是Ctrl-)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号
static NSString *se_getSignalName(int signal) {
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
    return name;
}

static NSArray *se_getStackSymbols() {
    void* callstack[1024];
    int frames = backtrace(callstack, 1024);
    char **strs = backtrace_symbols(callstack, frames);
    NSMutableArray *stack = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [stack addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return [stack copy];
}

static NSInteger se_getUncaughtExceptionCount() {
    volatile int32_t kUncaughtExceptionCount = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int32_t exceptionCount = OSAtomicIncrement32(&kUncaughtExceptionCount);
#pragma clang diagnostic pop
    return exceptionCount;
}

static void se_signalExceptionHandler(int signal) {
    if (se_getUncaughtExceptionCount() > UncaughtExceptionMaximum) {
        return;
    }
    NSDictionary *userInfo = @{@"signal" :@(signal)};
    NSString *reason = [NSString stringWithFormat:@"Signal %d was raised.",signal];
    NSException *exception = [NSException exceptionWithName:se_getSignalName(signal) reason:reason userInfo:userInfo];
    exception.se_callStackSymbols = se_getStackSymbols();
    if (se_uncaughtExceptionHandler) {
        se_uncaughtExceptionHandler(exception);
    }
}

static void se_NSSetSignalExceptionHandler(se_NSSignalExceptionHandler *handler) {
    signal(SIGABRT, handler);
    signal(SIGILL, handler);
    signal(SIGSEGV, handler);
    signal(SIGFPE, handler);
    signal(SIGBUS, handler);
    signal(SIGPIPE, handler);
    
    signal(SIGHUP, handler);
    signal(SIGINT, handler);
    signal(SIGQUIT, handler);
}

NSUncaughtExceptionHandler * _Nullable NSGetSignalExceptionHandler(void) {
    return se_uncaughtExceptionHandler;
}

void NSSetSignalExceptionHandler(NSUncaughtExceptionHandler * handel) {
    se_uncaughtExceptionHandler = handel;
    if (handel == NULL) {
        se_NSSetSignalExceptionHandler(NULL);
    }else{
        se_NSSetSignalExceptionHandler(&se_signalExceptionHandler);
    }
}


NSUncaughtExceptionHandler * _Nullable NSGetAllExceptionHandler(void) {
    return se_allExceptionHandler;
}

void NSSetAllExceptionHandler(NSUncaughtExceptionHandler * handel) {
    se_allExceptionHandler = handel;
    NSSetUncaughtExceptionHandler (handel);
    NSSetSignalExceptionHandler (handel);
}


#import <sys/sysctl.h>
#import <unistd.h>
bool NSAppIsBeingTraced(void) {
    struct kinfo_proc procInfo;
    size_t structSize = sizeof(procInfo);
    int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    if(sysctl(mib, sizeof(mib)/sizeof(*mib), &procInfo, &structSize, NULL, 0) != 0) {
        return false;
    }
    return (procInfo.kp_proc.p_flag & P_TRACED) != 0;
}


