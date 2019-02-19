# UException
捕获崩溃异常信息，（时间、堆栈、截屏）

### 使用方式
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    uExceptionHandler(YES, ^(UException *ue) {
        //exception 崩溃信息
    });
    return YES;
}
```
