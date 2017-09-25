//
//  MFSSafariIDManager.h
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>

@interface MFSSafariIDManager : NSObject <SFSafariViewControllerDelegate>

+ (void)setDeviceId:(NSString *)deviceId;
+ (NSString *)deviceId;

/**
 增加外部控制处理某些特殊情况，需在-application:didFinishLaunchingWithOptions:中设置
 @param enable 设YES则添加Safari Cookie流程，默认NO
 */
+ (void)enable:(BOOL)enable;

@end
