//
//  MFSIdentifier.h
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 imfong.com. All rights reserved.
//  Version 1.0.0 , updated_at 2017-04-19. https://github.com/maxfong/MFSIdentifier

#import <Foundation/Foundation.h>

@interface MFSIdentifier : NSObject

+ (NSString *)idfa;
+ (NSString *)idfv;

/** 设备标识符
 SafariCookie -> MFSCache -> iCloud -> IDFA -> IDFV -> NSUUID
 iOS9.0及以上支持存储Safari Cookie，可以设置[MFSCacheUtility registerAESKey:]达到其他应用获取了数据也无法正确解密
 iCloud方案需设置TARGETS的Capabilities，开启iCloud并设置Key-value storage
 */
+ (NSString *)deviceID;

@end

