//
//  ASLRSlide.h
//  UException
//
//  Created by YLCHUN on 2017/2/20.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ASLRSlide : NSObject
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) NSInteger address;
@property (nonatomic, assign) NSInteger slide;

@property (nonatomic, readonly) NSString *slideStr;
@property (nonatomic, readonly) NSString *addressStr;

+(NSArray<ASLRSlide*>*) slides;

@end
