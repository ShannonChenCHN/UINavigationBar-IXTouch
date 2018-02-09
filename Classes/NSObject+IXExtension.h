//
//  NSObject+IXExtension.h
//  InterstellarX
//
//  Created by ShannonChen on 2017/9/23.
//  Copyright © 2017年 InterstellarX. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Method Swizzling
 http://nshipster.cn/method-swizzling/
 */
@interface NSObject (Swizzling)

+ (void)ix_exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2;


@end
