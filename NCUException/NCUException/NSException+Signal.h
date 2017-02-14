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

