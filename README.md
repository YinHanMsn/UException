# UException
捕获崩溃异常信息，（时间、堆栈、截屏）

### UException
```
@interface UException : NSObject

@property (readonly, copy) NSDate *time;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *reason;
@property (readonly, copy) NSDictionary *userInfo;

@property (readonly, copy) NSArray<NSNumber *> *callStackReturnAddresses;
@property (readonly, copy) NSArray<NSString *> *callStackSymbols;

@property (readonly, retain) NSData *screenshot;

@property (readonly, copy) NSString* exceptionString;

@end

/**
手动截获异常信息，默认直接打印

@param handler 返回YES继续打印
*/
void uExceptionHandler(BOOL doPrint, void(^handler)(UException* ue));

/**
配置截屏

@param screenshot YES开启截屏，默认NO
*/
void uExceptionScreenshot(BOOL screenshot);
```

### NSException 扩展
```
//FOUNDATION_EXPORT NSUncaughtExceptionHandler * _Nullable NSGetUncaughtExceptionHandler(void);
//FOUNDATION_EXPORT void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler * _Nullable);

FOUNDATION_EXPORT NSUncaughtExceptionHandler * _Nullable NSGetSignalExceptionHandler(void);
FOUNDATION_EXPORT void NSSetSignalExceptionHandler(NSUncaughtExceptionHandler * _Nullable);

FOUNDATION_EXPORT NSUncaughtExceptionHandler * _Nullable NSGetAllExceptionHandler(void);
FOUNDATION_EXPORT void NSSetAllExceptionHandler(NSUncaughtExceptionHandler * _Nullable);


/**
app是否在调试模式下运行

@return true 调试模式下运行
*/
FOUNDATION_EXPORT bool NSAppIsBeingTraced(void);

```

### 使用方式
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    uExceptionHandler(YES, ^(UException *ue) {
        //exception 崩溃信息
    });
    return YES;
}
```
