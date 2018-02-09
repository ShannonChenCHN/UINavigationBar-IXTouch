//
//  UINavigationBar+IXTouch.h
//  TalentCat
//
//  Created by ShannonChen on 2018/2/9.
//  Copyright © 2018年 YHOUSE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (IXTouch)

/// 针对 iOS 11 下按钮点击范围被限制的问题作了特殊处理
+ (void)ix_registerCustomTouchViewClass:(Class)viewClass;

@end
