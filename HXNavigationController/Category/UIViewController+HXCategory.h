//
//  UIViewController+HXCategory.h
//  HXNavigationController
//
//  Created by Jney on 2017/8/21.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HXCategory)

/**
 设置rightBarButtonItem

 @param iconName 图片名称
 @param action rightBarButtonItem执行方法
 */
- (void)hx_setRightBarItemIcon:(NSString *)iconName action:(SEL)action;

/**
 设置NavigationBar透明
 */
- (void)hx_setNavigationBarAlpha:(CGFloat)alpha;

/**
 恢复NavigationBar
 */
- (void)hx_resumeNavigationBar;
@end
