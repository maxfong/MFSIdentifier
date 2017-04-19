//
//  NSDictionary+MFSIDURLQuery.m
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import "NSDictionary+MFSIDURLQuery.h"

@implementation NSDictionary (MFSIDURLQuery)

+ (instancetype)mfsid_dictionaryWithURLQuery:(NSString *)query {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (query.length && [query rangeOfString:@"="].location != NSNotFound) {
        NSArray *keyValuePairs = [query componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs) {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            NSString *paramValue = pair.count == 2 ? pair.lastObject : @"";
            parameters[pair.firstObject] = ({
                NSString *input = [paramValue stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, paramValue.length)];
                [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }) ?: @"";
        }
    }
    return parameters;
}

@end
