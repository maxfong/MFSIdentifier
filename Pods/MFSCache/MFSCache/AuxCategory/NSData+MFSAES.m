//
//  NSData+MFSAES.m
//  MFSCache
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 MFS. All rights reserved.
//

#import "NSData+MFSAES.h"
#import <CommonCrypto/CommonCryptor.h> 
#import "MFSCacheManager.h"

static const unsigned char MFSCache_AES_IV[] =
{ 0x54, 0x43, 0x4D, 0x6F, 0x62, 0x69, 0x6C, 0x65, 0x5B, 0x41, 0x45, 0x53, 0x5F, 0x49, 0x56, 0x5D };
NSString * const MFSCachePublicAESKey = @"MFSCache.maxfong";
NSString * const MFSCachePrivateAESKey = @"MFSCachePrivateAESKey";
NSString * const MFSCachePrivateAESSuiteName = @"com.imfong.cache.document";

@implementation NSData (MFSAES)

- (NSString *)mfscache_AESKey {
    MFSCacheManager *cacheManager = [[MFSCacheManager alloc] initWithSuiteName:MFSCachePrivateAESSuiteName];
    NSString *key = [cacheManager objectForKey:MFSCachePrivateAESKey];
    return key ?: MFSCachePublicAESKey;
}

- (NSData *)mfscache_AESEncrypt {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.mfscache_AESKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          [[NSData dataWithBytes:MFSCache_AES_IV length:sizeof(MFSCache_AES_IV)] bytes],
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)mfscache_AESDecrypt {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.mfscache_AESKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          [[NSData dataWithBytes:MFSCache_AES_IV length:sizeof(MFSCache_AES_IV)] bytes],
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
