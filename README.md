# UINavigationBar-IXTouch

简单、优雅地解决 iOS 11 导航栏自定义按钮布局和触摸事件响应的问题。


### 背景

在 iOS 11 下，UINavigationBar 中左右两侧的自定义按钮，会出现位置受限的问题，我们可以通过在创建 UIBarButtonItem 时设置 custom view 的布局，但是又会出现部分区域不能接收到点击事件。



### 解决思路

1.创建 UIBarButtonItem 时，设置 UIBarButtonItem 的 custom view，因为 custom view 的位置和大小会被系统限制住，所以可以把这个  custom view 作为一个容器，在其上添加一个 button。


2.因为在 custom view 上添加的 button 有可能在超出 custom view 的 bounds 范围，所以为了保证 button 能够被响应，我们需要将 custom view 上接收到的点击事件传给这个 button。

``` Objective-C
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
```

3.在 iOS 11 下，系统的导航栏有一个叫做 `_UINavigationBarContentView` 的子控件，会把导航栏上的点击事件拦截掉，所以我们需要从 UINavigationBar 的 view 层级中找到我们的 custom view，并在  UINavigationBar 的 `hitTest:withEvent:` 中将点击事件传给这个 custom view，这样我们的 button 就能接收点击事件了。

```
NS_INLINE UIView *IXFindIXOutsideTouchViewInView(UIView *view) {
    for (UIView *subview in view.subviews) {

        if ([subview isKindOfClass:[IXOutsideTouchView class]]) {
            return subview;
        } else {
            UIView *theView = IXFindIXOutsideTouchViewInView(subview);
            if (theView) {
                return theView;
            }
        }
    }
    
    return nil;
}

@implementation IXNavigationBar


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 针对 iOS 11 下按钮点击范围被限制的问题作了修改
    if (@available(iOS 11,*)) {
        
        // 递归遍历所有子 view，直到找到 IXOutsideTouchView，并且该 view 还能响应
        // 1. 一个一个问 subview，是否是 IXOutsideTouchView
        // 2. 如果是，就直接返回，如果不是，就继续问 subview 的 subview，递归询问
        // 3. 如果一直没找到，就什么都不做，继续往下执行
        // 4. 如果最终找到了，就调用 hitTest:withEvent: 方法，询问是否有可响应的 view
        
        UIView *view = IXFindIXOutsideTouchViewInView(self);
        if (view) {
            UIView *finalView = [view hitTest:[self convertPoint:point toView:view] withEvent:event];
            if (finalView) {
                return finalView;
            }
            
        }
    }

    
    return [super hitTest:point withEvent:event];
}

@end


```

### 更优雅的封装
按照上面的几个步骤，就已经可以实现我们想要达到的目的了，但是 navigation bar 需要知道自定义 view，耦合度比较高，而且还必须要自定义 UINavigationBar 的子类。


所以，我们可以通过 runtime 的 Method Swizzling 技术结合 category 来实现上面的第三步：
  
``` Objective-C 
typedef UIView *(^IXViewHitTestBlock)(UIView *view);


/**
 在 view 层级中找到指定 class 的 container view 的响应接受者

 @param customViewClasses 自定义 class
 @param containerView 容器 view
 @param hitTestBlock 是否接收响应事件
 @return 如果找到就返回一个 view，没找到则返回 nil。
 */
NS_INLINE UIView *IXFindTouchEventReceiverForCustomViewInView(NSArray <Class> *customViewClasses, UIView *containerView, IXViewHitTestBlock hitTestBlock) {
   
    for (UIView *subview in containerView.subviews) {
        
        if ([customViewClasses containsObject:subview.class] && hitTestBlock(subview)) { // 是自定义 view，并且能接收响应
            return hitTestBlock(subview);
        } else {
            // 如果不符合条件，就从 subview 开始找
            UIView *theView = IXFindTouchEventReceiverForCustomViewInView(customViewClasses, subview, hitTestBlock);
            if (theView) {
                return theView;
            }
        }
    }
    
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////

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
        
        UIView *view = IXFindTouchEventReceiverForCustomViewInView(m_registeredCustomTouchViewClasses, self, ^(UIView *aView){
            return [aView hitTest:[self convertPoint:point toView:aView] withEvent:event];
        });
        
        if (view) return view;
    }
    
    return [self ix_hitTest:point withEvent:event];
}

@end
```

当需要为自定义导航栏按钮拦截点击事件时，只需要注册这个 view 的 class 就行了。而且，如果你在导航上使用了多个不同类的 custom view，会按照注册先后顺序进行询问，只有最先注册的而且能做出响应的（响应范围合法）才会接收到点击事件。

将上面几个步骤合起来，再用 UIBarButtonItem 的 category 进行封装，就是这样的效果：

``` Objective-C
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
    
    return item;
}

```

详细的实现见 [源代码](https://github.com/ShannonChenCHN/UINavigationBar-IXTouch/tree/master/Classes)。

### 使用效果


``` Objective-C

self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithImage:[UIImage imageNamed:@"navigationbar_back_black"]
                                                           imageEdgeInsets:UIEdgeInsetsZero
                                                                    target:self
                                                                    action:@selector(pop)];
```
