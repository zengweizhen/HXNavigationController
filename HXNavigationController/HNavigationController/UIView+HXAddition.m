//
//  UIView+CCAddition.m
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "UIView+HXAddition.h"

@implementation UIView (HXAddition)

- (UIImage *)snapshotImage
{
	UIView *view = self;

	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return image;
}
@end
