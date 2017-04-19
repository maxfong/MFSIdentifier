//
//  MFSIdentifier.m
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import "MFSIdentifier.h"
#import "MFSCache.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import "MFSKeyChain.h"
#import "MFSSafariIDManager.h"
#import "NSString+MFSEncrypt.h"

NSString *const kMFSIdentifierKeyChainKey = @"com.imfong.MFSIdentifier.KeyChain";
NSString *const kMFSIdentifierCacheDeviceIdKey = @"com.imfong.MFSIdentifier.CacheDeviceId";
NSString *const kMFSIdentifierUserDeviceIdKey = @"com.imfong.MFSIdentifier.UserDeviceId";

@implementation MFSIdentifier

+ (NSString *)idfa {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return nil;
}

+ (NSString *)idfv {
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

+ (NSString *)deviceID {
    NSString *cacheDeviceId = [cacheManager() objectForKey:kMFSIdentifierCacheDeviceIdKey];
    NSString *userDeviceId = [userDefaults() objectForKey:kMFSIdentifierUserDeviceIdKey];
    //缓存和UserDefaults数据一致，验证通过
    if (cacheDeviceId.length && userDeviceId.length && [cacheDeviceId isEqualToString:userDeviceId]) {
        NSString *cookieDeviceId = [MFSSafariIDManager deviceId];
        //cookieDID存在，则以cookieDID为准（cookieDID值会进行AES解密，理论上安全可信）
        if (cookieDeviceId.length && ![cookieDeviceId isEqualToString:cacheDeviceId]) {
            return cookieDeviceId;
        }
        return cacheDeviceId;
    }
    else {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *keyChainKey = [[NSString stringWithFormat:@"%@%@", kMFSIdentifierKeyChainKey, bundleIdentifier] mfscache_md5];
        NSString *deviceId = [MFSKeyChain objectForKey:keyChainKey];
        if (!deviceId.length) {
            deviceId = [MFSSafariIDManager deviceId];
            if (!deviceId.length) {
                deviceId = cacheDeviceId;
                if (!deviceId.length) {
                    deviceId = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:kMFSIdentifierUserDeviceIdKey];
                    if (!deviceId.length) {
                        deviceId = [self idfa];
                        if (!deviceId.length) {
                            deviceId = [self idfv];
                            if (!deviceId.length) {
                                deviceId = [[NSUUID UUID] UUIDString];
                            }
                        }
                    }
                }
            }
        }
        if (deviceId.length) {
            [MFSKeyChain setObject:deviceId forKey:keyChainKey];
            [cacheManager() setObject:deviceId forKey:kMFSIdentifierCacheDeviceIdKey duration:-1];
            [userDefaults() setObject:deviceId forKey:kMFSIdentifierUserDeviceIdKey];
            [[NSUbiquitousKeyValueStore defaultStore] setString:deviceId forKey:kMFSIdentifierUserDeviceIdKey];
            [userDefaults() synchronize];
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        }
        return deviceId;
    }
}

#pragma mark -
static MFSCacheManager *cacheManager() {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFSCacheManager alloc] initWithSuiteName:@"com.imfong.MFSIdentifier.Cache"];
    });
    return instance;
}

static NSUserDefaults *userDefaults() {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSUserDefaults alloc] initWithSuiteName:@"com.imfong.MFSIdentifier.userDefaults"];
    });
    return instance;
}

@end
