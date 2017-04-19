//
//  MFSCacheUtility.m
//  MFSCache
//
//  Created by maxfong on 15/8/14.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import "MFSCacheUtility.h"
#import "MFSCacheManager.h"

extern NSString * const MFSCachePrivateAESKey;
extern NSString * const MFSCachePrivateAESSuiteName;

@interface MFSCacheUtility ()

@property (nonatomic, strong) NSMutableArray *sizeArray;
@property (nonatomic, strong) NSMutableArray *cleanArray;

@end

@implementation MFSCacheUtility

+ (instancetype)defaultCacheUtility {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (NSMutableArray *)sizeArray {
    return _sizeArray ?: ({
        _sizeArray = [NSMutableArray array];
    });
}
- (NSMutableArray *)cleanArray {
    return _cleanArray ?: ({
        _cleanArray = [NSMutableArray array];
    });
}

#pragma mark - 缓存大小返回
+ (void)sizeWithBlock:(void (^)(NSInteger totalSize))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MFSCacheUtility *utility = [MFSCacheUtility defaultCacheUtility];
        __block NSInteger totalSize = 0;
        [utility.sizeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MFSCacheUtilitySizeBlock handleBlock = obj;
            handleBlock(^(NSInteger size) {
                totalSize += size;
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) { block(totalSize); }
        });
    });
}
+ (void)registerCacheSizeBlock:(MFSCacheUtilitySizeBlock)block {
    if (block) {
        MFSCacheUtility *utility = [MFSCacheUtility defaultCacheUtility];
        [utility.sizeArray addObject:block];
    }
}

#pragma mark - 缓存清理注册
+ (void)registerCacheCleanBlock:(void (^)())block {
    if (block) {
        MFSCacheUtility *utility = [MFSCacheUtility defaultCacheUtility];
        [utility.cleanArray addObject:block];
    }
}
+ (void)cleanWithCompleteBlock:(void (^)())completeBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MFSCacheUtility *utility = [MFSCacheUtility defaultCacheUtility];
        [utility.cleanArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            void (^block)(void) = obj;
            if (block) { block(); }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) { completeBlock(); }
        });
    });
}

#pragma mark -
+ (void)registerAESKey:(NSString *)key {
    MFSCacheManager *cacheManager = [[MFSCacheManager alloc] initWithSuiteName:MFSCachePrivateAESSuiteName];
    [cacheManager setObject:key forKey:MFSCachePrivateAESKey];
}

@end
