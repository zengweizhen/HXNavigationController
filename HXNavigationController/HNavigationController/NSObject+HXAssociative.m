//
//  NSObject+CCAssociative.m
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "NSObject+HXAssociative.h"

#import <objc/runtime.h>

@implementation NSObject (HXAssociative)

static char associativeObjectsKey;

- (id)associativeObjectForKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    return [dict objectForKey:key];
}

- (void)removeAssociatedObjectForKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    [dict removeObjectForKey:key];
}

- (void)setAssociativeObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &associativeObjectsKey, dict, OBJC_ASSOCIATION_RETAIN);
    }

    if (object == nil) {
        [dict removeObjectForKey:key];
    } else {
        [dict setObject:object forKey:key];
    }
}

@end
