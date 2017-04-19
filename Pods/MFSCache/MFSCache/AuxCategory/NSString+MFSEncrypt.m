//
//  NSString+MFSEncrypt.m
//  MFSCache
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 MFS. All rights reserved.
//

#import "NSString+MFSEncrypt.h"
#import "CommonCrypto/CommonDigest.h"
#import "NSData+MFSAES.h"

@implementation NSString (MFSEncrypt)

- (NSString *)mfscache_md5 {
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

- (NSString *)mfscache_AESEncryptAndBase64Encode {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrypt = [data mfscache_AESEncrypt];
    NSData *base64Data = [encrypt base64EncodedDataWithOptions:0];
    NSString *secret = nil;
    if (encrypt) secret = [NSString stringWithUTF8String:[base64Data bytes]];
    return [secret stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

- (NSString *)mfscache_AESDecryptAndBase64Decode {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSData *decrypt = [data mfscache_AESDecrypt];
    NSString *secret = nil;
    if (decrypt) secret = [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
    return secret;
}

@end
