//
//  UIBarButtonItem+IXExtension.h
//  InterstellarX
//
//  Created by ShannonChen on 2017/9/23.
//  Copyright © 2017年 InterstellarX. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 封装 custom view 的 UIBarButtonItem
 */
@interface UIBarButtonItem (IXExtension)

+ (instancetype)leftItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (instancetype)leftItemWithImage:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)insets target:(id)target action:(SEL)action;

@end
