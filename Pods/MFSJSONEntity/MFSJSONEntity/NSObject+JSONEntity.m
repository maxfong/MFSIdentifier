//
//  NSObject+JSONEntity.m
//  MFSJSONEntity
//
//  Created by maxfong.
//  Copyright (c) 2013年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSJSONEntity

#import "NSObject+JSONEntity.h"
#import "NSObject+MFSJSONEntity.h"

@implementation NSObject (JSONEntity)

- (NSDictionary *)propertyDictionary
{
    return [self mfs_propertyDictionary];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary
{
    return [self mfs_objectWithDictionary:dictionary];
}

+ (id)objectWithArray:(NSArray *)array
{
    NSMutableArray *ret_Array = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id dict, NSUInteger idx, BOOL *stop) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            id obj = [self objectWithDictionary:dict];
            if (obj) [ret_Array addObject:obj];
        } else {
            [ret_Array removeAllObjects];
            [ret_Array addObjectsFromArray:array];
            *stop = YES;
        }
    }];
    return ret_Array;
}

+ (NSArray *)propertyNames
{
    return [self propertyNamesUntilClass:[self class]];
}

+ (NSArray *)propertyNamesUntilClass:(Class)cls
{
    return [self propertyNamesUntilClass:cls usingBlock:nil];
}

+ (NSArray *)propertyNamesUntilClass:(Class)cls usingBlock:(void (^)(NSString *propertyName))block
{
    return [self mfs_propertyNamesUntilClass:cls usingBlock:^(NSString *propertyName, NSString *propertyType) {
        if (block) block(propertyName);
    }];
}

@end
