//
//  AppDelegate.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "AppDelegate.h"
#import "NCUException.h"

@interface AppDelegate ()
@property (nonatomic, assign) BOOL cancelRun;
@end

@implementation AppDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:1 animated:NO];
    self.cancelRun = NO;
}

-(void)exceptionAlert:(NCUException*)exception {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"程序出现了异常" message:exception.exceptionString delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"继续", nil];
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!self.cancelRun) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    CFRelease(allModes);
}
#pragma clang diagnostic pop


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    uExceptionHandler(^BOOL(NCUException *ue) {
        [self exceptionAlert:ue];
        return YES;
    });
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
