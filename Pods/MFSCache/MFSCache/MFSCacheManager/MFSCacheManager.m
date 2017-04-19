//
//  MFSCacheManager.m
//  MFSCache
//
//  Created by maxfong on 15/7/6.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import "MFSCacheManager.h"
#import "MFSCacheStorage.h"

NSString * const MFSCacheManagerObject = @"MFSCacheManagerObject";
NSString * const MFSCacheManagerSetObjectNotification = @"MFSCacheManagerSetObjectNotification";
NSString * const MFSCacheManagerGetObjectNotification = @"MFSCacheManagerGetObjectNotification";
NSString * const MFSCacheManagerRemoveObjectNotification = @"MFSCacheManagerRemoveObjectNotification";

@interface MFSCacheManager ()

@property (nonatomic, strong) NSString *suiteName;
@property (nonatomic, strong) MFSCacheStorage *fileStorage;
@property (nonatomic, strong) NSMutableDictionary *tmpDatas;

@end

@implementation MFSCacheManager

+ (MFSCacheManager *)defaultManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = self.new; });
    return instance;
}

- (instancetype)initWithSuiteName:(NSString *)suitename {
    if (self = [self init]) {
        self.suiteName = suitename;
    }
    return self;
}

- (MFSCacheStorage *)fileStorage {
    return _fileStorage ?: ({ MFSCacheStorage *fileStorage = MFSCacheStorage.new; fileStorage.suiteName = self.suiteName; _fileStorage = fileStorage; });
}

- (NSMutableDictionary *)tmpDatas {
    return _tmpDatas ?: ({ _tmpDatas = [NSMutableDictionary dictionary]; });
}

#pragma mark -
- (void)setObject:(id)aObject forKey:(NSString *)aKey {
    [self setObject:aObject forKey:aKey duration:0];
}
- (void)setObject:(id)aObject forKey:(NSString *)aKey duration:(NSTimeInterval)duration {
    if (!aKey) return;
    if (!aObject) {
        [self removeObjectForKey:aKey]; return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MFSCacheManagerSetObjectNotification object:@{MFSCacheManagerObject:@{aKey : aObject}}];
    MFSCacheStorageObject *object = [[MFSCacheStorageObject alloc] initWithObject:aObject];
    object.timeoutInterval = duration;
    if (object.storageString) [self.fileStorage setObject:object forKey:aKey];
}

- (void)setObject:(id)aObject forKey:(NSString *)aKey toDisk:(BOOL)toDisk {
    if (!aKey) return;
    if (!aObject) {
        [self removeObjectForKey:aKey]; return;
    }
    if (toDisk) {
        [self setObject:aObject forKey:aKey];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MFSCacheManagerSetObjectNotification object:@{MFSCacheManagerObject:@{aKey : aObject}}];
        [self.tmpDatas setObject:aObject forKey:aKey];
    }
}

#pragma mark -
- (id)objectForKey:(NSString *)aKey {
    if (!aKey) return nil;
    return self.tmpDatas[aKey] ?: ({
        MFSCacheStorageObject *object = [self.fileStorage objectForKey:aKey];
        id returnObject = [object storageObject];
        if (!returnObject) return nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:MFSCacheManagerGetObjectNotification object:@{MFSCacheManagerObject:@{aKey : returnObject}}];
        returnObject;
    });
}
/** 异步根据Key获取缓存对象 */
- (void)objectKey:(NSString *)aKey completion:(void (^)(id obj))block {
    if (!aKey) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id obj = [self objectForKey:aKey];
        if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(obj); });
    });
}

#pragma mark -
- (void)removeObjectForKey:(NSString *)aKey {
    if (!aKey) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:MFSCacheManagerRemoveObjectNotification object:aKey];
    [self.fileStorage removeObjectForKey:aKey];
    [self.tmpDatas removeObjectForKey:aKey];
}

- (void)removeObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock {
    [self.fileStorage removeDefaultObjectsWithCompletionBlock:completionBlock];
}
- (void)removeExpireObjects {
    [self.fileStorage removeExpireObjects];
}

+ (void)removeObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock {
    [MFSCacheStorage removeDefaultObjectsWithCompletionBlock:completionBlock];
}
+ (void)removeExpireObjects {
    [MFSCacheStorage removeExpireObjects];
}

@end
