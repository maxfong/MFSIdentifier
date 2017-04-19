//
//  MFSKeyChain.h
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFSKeyChain : NSObject

+ (void)setObject:(id)anObject forKey:(NSString*)key;
+ (id)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

@end
