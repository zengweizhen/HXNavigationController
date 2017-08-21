//
//  UIViewController+HXCategory.m
//  HXNavigationController
//
//  Created by Jney on 2017/8/21.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "UIViewController+HXCategory.h"

@implementation UIViewController (HXCategory)

- (void)hx_setRightBarItemIcon:(NSString *)iconName action:(SEL)action{
    
    //设置UIBarButtonItem
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *spacerItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerItemButton.width = - 10;//这个数值可以根据情况自由变化
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems = @[spacerItemButton,rightItem];
    
}

- (void)hx_setNavigationBarAlpha:(CGFloat)alpha{
    
    self.navigationController.navigationBar.translucent = NO;//Bar的模糊效果，默认为YES
    ///设置navigationBar的颜色和title文字的颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = alpha;
}

- (void)hx_resumeNavigationBar{
    ///这里恢复系统之前默认的颜色(包括title的颜色)
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1];
    ///设置navigationTitle的样式为默认样式
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor blackColor]}];

    [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = 1;

}

@end
