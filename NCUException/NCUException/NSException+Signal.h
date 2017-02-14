//
//  NSException+Signal.h
//  NCUException
//
//  Created by YLCHUN on 2017/2/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException (Signal)

@end

FOUNDATION_EXPORT NSUncaughtExceptionHandler * _Nullable NSGetSignalExceptionHandler(void);
FOUNDATION_EXPORT void NSSetSignalExceptionHandler(NSUncaughtExceptionHandler * _Nullable);

FOUNDATION_EXPORT NSUncaughtExceptionHandler * _Nullable NSGetAllExceptionHandler(void);
FOUNDATION_EXPORT void NSSetAllExceptionHandler(NSUncaughtExceptionHandler * _Nullable);


//FOUNDATION_EXPORT void NSChangeUncaughtExceptionHandler(void (^ _Nonnull newHandler)(NSUncaughtExceptionHandler * _Nullable handler));//每(3/1000)秒内检测是否变化，有效时间3秒,执行一次
