//
//  ViewController.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "NCUException+Test.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:2];
        //    signalException();//需要在模拟器或者真机上直接启动测试
        uncaughtException();
    });
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
