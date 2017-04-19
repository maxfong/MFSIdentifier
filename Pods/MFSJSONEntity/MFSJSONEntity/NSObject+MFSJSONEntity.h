//
//  NSObject+MFSJSONEntity.h
//  MFSJSONEntity
//
//  Created by maxfong.
//  Copyright (c) 2013年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSJSONEntity

#import <Foundation/Foundation.h>
#import "MFSJSONEntityElementProtocol.h"
#import "MFSJSONEntityPropertyProtocol.h"

@interface NSObject (MFSJSONEntity) <MFSJSONEntityElementProtocol, MFSJSONEntityPropertyProtocol>

/** 获取当前对象的属性集合 */
- (NSDictionary *)mfs_propertyDictionary;

/**
 *  根据数据集合&类型，获取对象
 *
 *  @param dictionary 数据集合
 *
 *  @return 对象实例
 */
+ (id)mfs_objectWithDictionary:(id)dictionary;

/** 获取当前对象的属性列表，截至NSObject */
+ (NSArray *)mfs_propertyNamesUntilClass:(Class)cls usingBlock:(void (^)(NSString *propertyName, NSString *propertyType))block;

@end
