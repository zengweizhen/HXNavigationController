//
//  NSObject+CCAssociative.h
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HXAssociative)

- (id)associativeObjectForKey:(NSString *)key;
- (void)removeAssociatedObjectForKey:(NSString *)key;
- (void)setAssociativeObject:(id)object forKey:(NSString *)key;

@end
