//
//  ViewController.m
//  Example
//
//  Created by ShannonChen on 2018/2/9.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "UIBarButtonItem+IXExtension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 自定义返回按钮
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithImage:[UIImage imageNamed:@"navigationbar_back_black"] imageEdgeInsets:UIEdgeInsetsZero target:self action:@selector(pop)];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 滑动返回
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}

- (IBAction)push:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
