//
//  CCSlideAnimatedTransitioning.h
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HXSlideAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isReverse) BOOL reverse;
@property (nonatomic, assign) CGFloat transitioningInitailOriginX;

- (instancetype)initWithReverse:(BOOL)reverse;
+ (instancetype)transitioningWithReverse:(BOOL)reverse;

@end
