//
//  UIBarButtonItem+IXExtension.m
//  InterstellarX
//
//  Created by ShannonChen on 2017/9/23.
//  Copyright © 2017年 InterstellarX. All rights reserved.
//

#import "UIBarButtonItem+IXExtension.h"
#import "IXOutsideTouchView.h"
#import <objc/runtime.h>
#import "UINavigationBar+IXTouch.h"

#define kNavigationBarHeight                         44.0
#define kBarButtonImageEdgeInsets                   UIEdgeInsetsMake(0, -6, 0, 6)

static CGFloat const kImageBarButtonSidePadding = 16.0;


@implementation UIBarButtonItem (IXExtension)


+ (instancetype)leftItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    
    return [self leftItemWithImage:image imageEdgeInsets:kBarButtonImageEdgeInsets target:target action:action];
}

+ (instancetype)leftItemWithImage:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)insets target:(id)target action:(SEL)action {
    
    // 这个按钮才是真正要响应点击事件的控件
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(-kImageBarButtonSidePadding, 0, kNavigationBarHeight, kNavigationBarHeight)];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = insets;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    // 包装 button 的容器 view，这个 view 的位置和大小被限制死了，所以还需要把触摸事件传给 button
    IXOutsideTouchView *containerView = [[IXOutsideTouchView alloc] initWithFrame:CGRectMake(0, 0, kNavigationBarHeight, kNavigationBarHeight)];
    [containerView addSubview:button];
    
    // iOS 11 下的适配，将 UINavigationBar 上的触摸事件传到最上面的自定义控件，防止被系统的 _UINavigationBarContentView 拦截掉
    [UINavigationBar ix_registerCustomTouchViewClass:[IXOutsideTouchView class]];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    button.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6];
    containerView.backgroundColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];
    
    return item;
}


@end
