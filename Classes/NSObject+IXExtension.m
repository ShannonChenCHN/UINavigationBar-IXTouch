//
//  NSObject+IXExtension.m
//  InterstellarX
//
//  Created by ShannonChen on 2017/9/23.
//  Copyright © 2017年 InterstellarX. All rights reserved.
//

#import "NSObject+IXExtension.h"
#import <objc/runtime.h>


@implementation NSObject (Swizzling)

// http://nshipster.cn/method-swizzling/
+ (void)ix_exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2 {
    
    Class class = [self class];
    
    SEL originalSelector = method1;
    SEL swizzledSelector = method2;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

+ (void)ix_exchangeClassMethod1:(SEL)method1 method2:(SEL)method2 {
    
     Class class = [self class];
    
    SEL originalSelector = method1;
    SEL swizzledSelector = method2;
    
     Method originalMethod = class_getClassMethod(class, originalSelector);
     Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

@end
