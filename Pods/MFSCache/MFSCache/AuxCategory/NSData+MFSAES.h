//
//  NSData+MFSAES.h
//  MFSCache
//
//  Created by maxfong on 2017/4/17.
//  Copyright © 2017年 MFS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MFSAES)

- (NSData *)mfscache_AESEncrypt;
- (NSData *)mfscache_AESDecrypt;

@end
