//
//  NSString+MFSEncrypt.h
//  MFSCache
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 MFS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MFSEncrypt)

- (NSString *)mfscache_md5;
- (NSString *)mfscache_AESEncryptAndBase64Encode;
- (NSString *)mfscache_AESDecryptAndBase64Decode;

@end
