//
//  CCNavigationController.h
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNavigationController : UINavigationController<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat previousSlideViewInitailOriginX;
@property (nonatomic, assign, getter = isSlidingPopEnable) BOOL slidingPopEnable;							  //Default YES
@property (nonatomic, assign, getter = isUseSystemAnimatedTransitioning) BOOL useSystemAnimatedTransitioning; //Default NO
@property (nonatomic, assign) BOOL edgePopGestureOnly;

@property (nonatomic, assign) BOOL supportLandscape;

/**
 是否可以滑动返回
 */
@property (nonatomic, assign) BOOL gestureBack;

@property (nonatomic, assign) BOOL isBack;//表示返回

+ (void)setCacheSnapshotImageInMemory:(BOOL)cacheSnapshotImageInMemory;

@end
