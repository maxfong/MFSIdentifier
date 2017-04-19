//
//  MFSSafariIDManager.m
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import "MFSSafariIDManager.h"
#import "MFSCache.h"
#import "NSString+MFSEncrypt.h"
#import "NSString+MFSIDURLEncoded.h"

NSString *const kMFSSafariDeviceCacheSuiteName = @"com.imfong.MFSIdentifier.SafariDeviceCache";
NSString *const kMFSSafariHookDeviceIdURL = @"https://imfong.com/client/html/device.html";
NSString *const kMFSSafariHookBackIdentifier = @"//imfong.com/client/device";
NSString *const kMFSSafariDeviceIDIdentifier = @"deviceId";

@interface MFSSafariIDManager ()
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@end

@implementation MFSSafariIDManager

#pragma mark -
+ (void)setDeviceId:(NSString *)deviceId {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (deviceId.length) {
            NSArray *types = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
            NSArray *schemes = types.firstObject[@"CFBundleURLSchemes"];
            NSString *scheme = schemes.firstObject;
            if (scheme.length) {
                NSString *idEncode = [deviceId mfscache_AESEncryptAndBase64Encode];
                NSString *idBase64 = [idEncode mfsid_URLEncodedString];
                NSString *schemeBase64 = [scheme mfsid_URLEncodedString];
                NSString *url = [NSString stringWithFormat:@"%@?deviceId=%@&scheme=%@", kMFSSafariHookDeviceIdURL, idBase64, schemeBase64];
                [self openURL:[NSURL URLWithString:url]];
            }
        }
    });
}

+ (NSString *)deviceId {
    MFSCacheManager *cacheManager = [[MFSCacheManager alloc] initWithSuiteName:kMFSSafariDeviceCacheSuiteName];
    return [cacheManager objectForKey:kMFSSafariDeviceIDIdentifier];
}

#pragma mark - 
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSArray *types = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
            NSArray *schemes = types.firstObject[@"CFBundleURLSchemes"];
            NSString *scheme = schemes.firstObject;
            if (scheme.length) {
                NSString *urlString = [NSString stringWithFormat:@"%@?scheme=%@", kMFSSafariHookDeviceIdURL, scheme];
                if ([MFSSafariIDManager respondsToSelector:@selector(openURL:)]) {
                    [MFSSafariIDManager performSelector:@selector(openURL:) withObject:[NSURL URLWithString:urlString]];
                }
            }
        }];
    });
}

+ (instancetype)defaultManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

+ (void)openURL:(NSURL *)url {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (url && [url isKindOfClass:[NSURL class]] &&
        rootViewController &&
        [[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)
    {
        MFSSafariIDManager *safariManager = [MFSSafariIDManager defaultManager];
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        safariViewController.view.frame = CGRectMake(0, 0, 1, 1);
        safariViewController.delegate = safariManager;
        safariManager.safariViewController = safariViewController;
        
        [rootViewController addChildViewController:safariViewController];
        [rootViewController.view addSubview:safariViewController.view];
    }
}

#pragma mark - SFSafariViewControllerDelegate
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    [self.safariViewController.view removeFromSuperview];
    [self.safariViewController removeFromParentViewController];
}

@end
