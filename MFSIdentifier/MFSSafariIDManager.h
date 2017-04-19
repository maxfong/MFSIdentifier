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

@end
