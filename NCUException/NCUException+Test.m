//
//  NCUException+Test.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NCUException+Test.h"
#import <UIKit/UIKit.h>

@interface Test : NSObject{
   @public int a;
}

@end
static BOOL cancelRun;
@implementation Test

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:1 animated:NO];
    cancelRun = YES;
}

+(void)exceptionAlert:(NCUException*)exception {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"程序出现了异常" message:exception.exceptionString delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!cancelRun) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    CFRelease(allModes);
}
#pragma clang diagnostic pop

@end

void exceptionAlert(NCUException *exception) {
    [Test exceptionAlert:exception];
}

void signalException() {
//    abort();
    Test *t;
    t->a = 1;
}

void uncaughtException() {
    id i;
    NSMutableArray *arr = [NSMutableArray array];
    arr[0] = i;
    
}
