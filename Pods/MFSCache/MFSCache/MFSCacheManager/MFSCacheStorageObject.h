//
//  MFSCacheStorageObject.h
//  MFSCache
//
//  Created by maxfong on 15/7/6.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MFSCacheStorageObjectTimeOutInterval) {
    MFSCacheStorageObjectIntervalDefault,
    MFSCacheStorageObjectIntervalTiming,     //定时
    MFSCacheStorageObjectIntervalAllTime     //永久
};

@interface MFSCacheStorageObject : NSObject <NSCoding>

/** 数据String */
@property (nonatomic, copy, readonly) NSString *storageString;
/** 数据类名 */
@property (nonatomic, strong, readonly) id storageObject;
/** 数据的存储时效性 */
@property (nonatomic, assign, readonly) MFSCacheStorageObjectTimeOutInterval storageInterval;

/** 当前对象的标识符（KEY），默认会自动生成，可自定义*/
@property (nonatomic, copy) NSString *objectIdentifier;

/** 存储文件的过期时间
 *  -1表示永久文件，慎用 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/** 根据（String,URL,Data,Number,Dictionary,Array,Null,实体）初始化对象 */
- (instancetype)initWithObject:(id)object;

@end
