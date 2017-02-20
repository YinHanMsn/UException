//
//  ASLRSlide.m
//  NCUException
//
//  Created by YLCHUN on 2017/2/20.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ASLRSlide.h"
#import <mach-o/dyld.h>

@interface ASLRSlide ()
@property (nonatomic, copy) NSString *slideStr;
@property (nonatomic, copy) NSString *addressStr;
@end

@implementation ASLRSlide


+(NSArray<ASLRSlide*>*) slides {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < _dyld_image_count(); i++) {
        char *image_name = (char *)_dyld_get_image_name(i);
        const struct mach_header *mh = _dyld_get_image_header(i);
        intptr_t vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
        ASLRSlide *slide = [[ASLRSlide alloc] init];
        slide.imageName = [[NSString stringWithUTF8String:image_name] componentsSeparatedByString:@"/"].lastObject;
        slide.slide = vmaddr_slide;
        slide.address = (mach_vm_address_t)mh;
        [arr addObject:slide];
    }
    return arr;
}


-(NSString *)slideStr {
    if (!_slideStr) {
        _slideStr = [NSString stringWithFormat:@"0x%lx", self.slide];
    }
    return _slideStr;
}

-(NSString *)addressStr{
    if (!_addressStr) {
        _addressStr = [NSString stringWithFormat:@"0x%lx", self.address];
    }
    return _addressStr;
}
@end


