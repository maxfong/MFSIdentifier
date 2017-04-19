//
//  NSDictionary+MFSIDURLQuery.h
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MFSIDURLQuery)

/**
 *  根据URL.query查询参数的值
 *
 *  @param query URL.query
 *
 *  @return dictionary
 */
+ (instancetype)mfsid_dictionaryWithURLQuery:(NSString *)query;

@end
