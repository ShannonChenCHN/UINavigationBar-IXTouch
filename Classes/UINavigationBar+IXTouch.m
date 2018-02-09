//
//  UINavigationBar+IXTouch.m
//  TalentCat
//
//  Created by ShannonChen on 2018/2/9.
//  Copyright © 2018年 YHOUSE. All rights reserved.
//

#import "UINavigationBar+IXTouch.h"
#import "NSObject+IXExtension.h"
#import <objc/runtime.h>

/// 在 view 层级中找到指定 class 的 view
NS_INLINE UIView *IXFindCustomViewInView(NSArray <Class> *customViewClasses, UIView *containerView) {
   
    for (UIView *subview in containerView.subviews) {
        
        if ([customViewClasses containsObject:subview.class]) {
            return subview;
        } else {
            UIView *theView = IXFindCustomViewInView(customViewClasses, subview);
            if (theView) {
                return theView;
            }
        }
    }
    
    return nil;
}


@implementation UINavigationBar (IXTouch)

static NSMutableArray <Class> *m_registeredCustomTouchViewClasses = nil;

+ (void)load {
    [self ix_exchangeInstanceMethod1:@selector(hitTest:withEvent:) method2:@selector(ix_hitTest:withEvent:)];
}

+ (void)ix_registerCustomTouchViewClass:(Class)viewClass {
    
    if (!m_registeredCustomTouchViewClasses) {
        m_registeredCustomTouchViewClasses = [NSMutableArray array];
    }
    
    [m_registeredCustomTouchViewClasses addObject:viewClass];
    
}

// 触摸事件是按照这样的顺序传递的： UIApplication -> UIWindow -> root view -> subview -> subview... 直到找到合适的 view
// https://www.jianshu.com/p/2e074db792ba
- (UIView *)ix_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 针对 iOS 11 下按钮点击范围被限制的问题作了修改
    if (@available(iOS 11,*)) {
        
        // 递归遍历所有子 view，直到找到 IXOutsideTouchView，并且该 view 还能响应
        // 1. 一个一个问 subview，是否是 IXOutsideTouchView
        // 2. 如果是，就直接返回，如果不是，就继续问 subview 的 subview，递归询问
        // 3. 如果一直没找到，就什么都不做，继续往下执行
        // 4. 如果最终找到了，就调用 hitTest:withEvent: 方法，询问是否有可响应的 view
        
        UIView *view = IXFindCustomViewInView(m_registeredCustomTouchViewClasses, self);
        if (view) {
            UIView *finalView = [view hitTest:[self convertPoint:point toView:view] withEvent:event];
            if (finalView) {
                return finalView;
            }
            
        }
    }
    
    return [self ix_hitTest:point withEvent:event];
}

@end
