//
//  NCUException.h
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//
#define NCUException_enabled 1

#import <Foundation/Foundation.h>

@interface NCUException : NSObject

@property (readonly, copy) NSDate *time;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *reason;
@property (readonly, copy) NSDictionary *userInfo;

@property (readonly, copy) NSArray<NSNumber *> *callStackReturnAddresses;
@property (readonly, copy) NSArray<NSString *> *callStackSymbols;

@property (readonly, retain) NSData *screenshot;

@property (readonly, copy) NSString* exceptionString;

@end

#pragma mark - Handler or Config


/**
 手动截获异常信息，默认直接打印

 @param handler 返回YES继续打印
 */
void uExceptionHandler(BOOL(^handler)(NCUException* ue));

/**
 配置截屏

 @param screenshot YES开启截屏，默认NO
 */
void uExceptionScreenshot(BOOL screenshot);
