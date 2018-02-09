//
//  IXOutsideTouchView.m
//  InterstellarX
//
//  Created by ShannonChen on 2017/9/23.
//  Copyright © 2017年 InterstellarX. All rights reserved.
//

#import "IXOutsideTouchView.h"

@implementation IXOutsideTouchView

// allow touches outside view
// https://github.com/Automattic/simplenote-ios/blob/b43ffb63ae188fe263bf7419e44b7075ea7ddf22/Simplenote/Classes/SPOutsideTouchView.h
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for(UIView *aSubview in self.subviews) {
        UIView *view = [aSubview hitTest:[self convertPoint:point toView:aSubview] withEvent:event];
        if(view) return view;
    }
    return [super hitTest:point withEvent:event];
}

@end
