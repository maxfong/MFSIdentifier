//
//  MFSCacheStorage.h
//  MFSCache
//
//  Created by maxfong on 15/7/6.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import <Foundation/Foundation.h>
#import "MFSCacheStorageObject.h"

extern NSString * MFSCacheStorageDefaultFinderName;

typedef NS_ENUM(NSUInteger, MFSCacheStorageType) {
    MFSCacheStorageCache         = 0,    //Memory
    MFSCacheStorageArchiver
};

@interface MFSCacheStorage : NSObject

/** 空间，suiteName以.document结尾则数据保存至Document */
@property (nonatomic, strong) NSString *suiteName;

+ (instancetype)defaultStorage;

/** MFSCacheStorageType默认为MFSCacheStorageArchiver */
- (void)setObject:(MFSCacheStorageObject *)aObject forKey:(NSString *)aKey;
- (void)setObject:(MFSCacheStorageObject *)aObject forKey:(NSString *)aKey type:(MFSCacheStorageType)t;

- (MFSCacheStorageObject *)objectForKey:(NSString *)aKey;

- (void)removeObjectForKey:(NSString *)aKey;

//删除所有的默认文件，常用方法
- (void)removeDefaultObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock;
//删除过期的文件
- (void)removeExpireObjects;

/** 对所有空间做操作 */
/** 删除所有的默认文件，谨慎操作 */
+ (void)removeDefaultObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock;
/** 删除过期的文件，谨慎操作 */
+ (void)removeExpireObjects;

@end
