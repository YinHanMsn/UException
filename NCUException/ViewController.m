//
//  ViewController.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "NCUException+Test.h"
#include <execinfo.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)signalExceptionAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self toMain];
        signalException();
    });
}

-(void)toMain {
    dispatch_async(dispatch_get_main_queue(), ^{
        void* callstack[128];
        int frames = backtrace(callstack, 128);
        char **strs = backtrace_symbols(callstack, frames);
        long i;
        NSMutableArray *callStackSymbols = [NSMutableArray arrayWithCapacity:frames];
        for (i = 0; i < frames; i++) {
            [callStackSymbols addObject:[NSString stringWithUTF8String:strs[i]]];
        }
        free(strs);
        NSLog(@"signalException callStackSymbols: %@", callStackSymbols);
    });

}

- (IBAction)uncaughtExceptionAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //获取堆栈
        void* callstack[128];
        int frames = backtrace(callstack, 128);
        char **strs = backtrace_symbols(callstack, frames);
        long i;
        NSMutableArray *callStackSymbols = [NSMutableArray arrayWithCapacity:frames];
        for (i = 0; i < frames; i++) {
            [callStackSymbols addObject:[NSString stringWithUTF8String:strs[i]]];
        }
        free(strs);
        NSLog(@"uncaughtException callStackSymbols: %@", callStackSymbols);
        uncaughtException();
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
