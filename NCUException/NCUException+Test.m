//
//  NCUException+Test.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NCUException+Test.h"

@interface Test : NSObject{
   @public int a;
}
@end
@implementation Test
@end

void signalException() {
    Test *t;
    t->a = 1;
}

void uncaughtException() {
    NSArray *arr = [NSArray array];
    arr[0];
}
