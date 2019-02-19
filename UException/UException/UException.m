//
//  UException.m
//  UException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//


#import "UException.h"
#import "NSException+Signal.h"
#import <UIKit/UIKit.h>

#pragma mark - UException

@interface UException()
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) NSArray<NSNumber *> *callStackReturnAddresses;
@property (nonatomic, copy) NSArray<NSString *> *callStackSymbols;
@property (nonatomic, retain) NSData *screenshot;
@property (nonatomic, copy) NSString* appInfo;
@property (nonatomic, copy) NSString* exceptionString;

@end

@implementation UException

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

#pragma mark - _UException

@interface _UException :NSObject
@property (nonatomic, copy) BOOL(^ueHandler)(UException* ue);
@property (nonatomic, assign) BOOL screenshot;
-(void)exception:(UException*) exception;

@end

static _UException* _uException = nil;

void _UExceptionHandler(NSException *exception) {
    [_uException performSelectorOnMainThread:@selector(exception:) withObject:exception waitUntilDone:YES];
}

@implementation _UException

#if UException_enabled
+(void)load {
    [super load];
    [_UException shareInstance];
}
#endif

+(instancetype) shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _uException = [[super allocWithZone:NULL] init];
        NSSetAllExceptionHandler (&_UExceptionHandler);
    });
    return _uException ;
}

+(id) allocWithZone:(struct _NSZone *)zone {
    return [_UException shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone {
    return [_UException shareInstance];
}

-(void)exception:(NSException*)exception {
    NSSetAllExceptionHandler (NULL);
    
    UException * ue = [[UException alloc] init];
    ue.callStackSymbols = [exception callStackSymbols];
    ue.callStackReturnAddresses = [exception callStackReturnAddresses];
    ue.reason = [exception reason];
    ue.name = [exception name];
    ue.userInfo = [exception userInfo];
    
    if (self.screenshot) {
        ue.screenshot = [self dataWithScreenshotInPNGFormat];//截屏
    }
    
    BOOL b = YES;
    if (self.ueHandler) {
        b = self.ueHandler(ue);
    }
    if (b) {
        printf("%s", [ue.exceptionString UTF8String]);
    }
}


-(void)exceptionHandler:(BOOL(^)(UException* ue))handler {
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
void uExceptionHandler(BOOL doPrint, void(^handler)(UException* ue)) {
    [_uException exceptionHandler:^BOOL(UException *ue) {
        if (handler) {
            handler(ue);
        }
        return doPrint;
    }];
}

void uExceptionScreenshot(BOOL screenshot) {
    _uException.screenshot = screenshot;
}


