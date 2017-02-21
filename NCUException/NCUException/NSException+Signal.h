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
