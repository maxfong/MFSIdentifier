//
//  MFSIDDelegateHelper.m
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import "MFSIDDelegateHelper.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "MFSCache.h"
#import "MFSIdentifier.h"
#import "MFSSafariIDManager.h"
#import "NSString+MFSEncrypt.h"
#import "NSString+MFSIDURLEncoded.h"
#import "NSDictionary+MFSIDURLQuery.h"

extern NSString *const kMFSSafariHookBackIdentifier;
extern NSString *const kMFSSafariDeviceCacheSuiteName;
extern NSString *const kMFSIdentifierUserDeviceIdKey;
extern NSString *const kMFSSafariDeviceIDIdentifier;

IMP mfsid_hookClassMethod(Class oldcls, Class newcls, SEL oldSEL, SEL newSEL) {
    Method newMethod = class_getInstanceMethod(newcls, newSEL);
    IMP newMethodIMP = method_getImplementation(newMethod);
    const char * newTypes = method_getTypeEncoding(newMethod);
    Method oldMethod = class_getInstanceMethod(oldcls, oldSEL);
    if (oldMethod) {
        IMP methodIMP = method_getImplementation(oldMethod);
        method_exchangeImplementations(oldMethod, newMethod);
        return methodIMP;
    } else {
        class_addMethod(oldcls, oldSEL, newMethodIMP, newTypes);
    }
    return NULL;
}

typedef void (*MFSIDApplicationOpenURLOptionsIMP)(id, SEL, UIApplication *, NSURL *, NSDictionary *);
static MFSIDApplicationOpenURLOptionsIMP mfsid_openURLMethodIMP = NULL;

@implementation MFSIDDelegateHelper

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            mfsid_openURLMethodIMP = (MFSIDApplicationOpenURLOptionsIMP)mfsid_hookClassMethod([UIApplication sharedApplication].delegate.class, [MFSIDDelegateHelper class], @selector(application:openURL:options:), @selector(mfsid_application:openURL:options:));
        }];
    });
}

- (BOOL)mfsid_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    BOOL handled = [MFSIDDelegateHelper mfsid_hookHandleURL:url];
    if (handled) { return NO; }
    
    if (mfsid_openURLMethodIMP) {
        void (*impBlock)(id, SEL, UIApplication *, NSURL *, NSDictionary *) = mfsid_openURLMethodIMP;
        impBlock(self, @selector(application:openURL:options:), app, url, options);
    }
    return YES;
}

+ (BOOL)mfsid_hookHandleURL:(NSURL *)url {
    NSURL *verifyURL = [[NSURL alloc] initWithString:kMFSSafariHookBackIdentifier];
    BOOL equal = ([verifyURL.host isEqualToString:url.host] &&[verifyURL.path isEqualToString:url.path]);
    if (equal) {
        NSDictionary *dict = [NSDictionary mfsid_dictionaryWithURLQuery:url.query];
        NSString *idEncode = [dict[kMFSSafariDeviceIDIdentifier] mfsid_URLDecodedString];
        NSString *deviceId = [idEncode mfscache_AESDecryptAndBase64Decode];
        
        if (!deviceId.length) {
            deviceId = [MFSIdentifier deviceID];
            [MFSSafariIDManager setDeviceId:deviceId];
        }
        MFSCacheManager *cacheManager = [[MFSCacheManager alloc] initWithSuiteName:kMFSSafariDeviceCacheSuiteName];
        [cacheManager setObject:deviceId forKey:kMFSSafariDeviceIDIdentifier duration:-1];
        [[NSUbiquitousKeyValueStore defaultStore] setString:deviceId forKey:kMFSIdentifierUserDeviceIdKey];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    return equal;
}

@end
