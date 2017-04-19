//
//  MFSCacheStorageObject.m
//  MFSCache
//
//  Created by maxfong on 15/7/6.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import "MFSCacheStorageObject.h"
#import "NSJSONSerialization+MFSJSONString.h"
#import "MFSJSONEntity.h"
#import "NSString+MFSEncrypt.h"

@interface MFSCacheStorageObject ()

@property (nonatomic, copy, readwrite) NSString *storageString;
@property (nonatomic, strong) NSMutableDictionary *storageOptions;

@end

@implementation MFSCacheStorageObject

- (instancetype)initWithObject:(id)object {
    if (self = [self init]) {
        NSDictionary *dictionary = [self dictionaryWithObject:object];
        NSString *objectString = [NSJSONSerialization mfscache_stringWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        self.storageString = [objectString mfscache_AESEncryptAndBase64Encode];
    }
    return self;
}

- (id)storageObject {
    //AES解密
    NSString *objectString = [self.storageString mfscache_AESDecryptAndBase64Decode];
    NSDictionary *dictionary = [NSJSONSerialization mfscache_objectWithJSONString:objectString options:NSJSONReadingAllowFragments error:nil];
    return [self storageObjectWithDictionary:dictionary];
}

- (id)storageObjectWithDictionary:(NSDictionary *)dictionary {
    __block id returnObject = nil;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *className, id obj, BOOL *stop) {
        Class cls = NSClassFromString(className);
        if ([cls isSubclassOfClass:[NSString class]]) {
            returnObject = [NSMutableString stringWithString:obj];
        }
        else if ([cls isSubclassOfClass:[NSURL class]]) {
            returnObject = [NSURL URLWithString:obj];
        }
        else if ([cls isSubclassOfClass:[NSNumber class]]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            returnObject = [numberFormatter numberFromString:obj];
        }
        else if ([cls isSubclassOfClass:[NSData class]]) {
            returnObject = [obj dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([cls isSubclassOfClass:[NSDictionary class]]) {
            __block NSMutableDictionary *mutDictionary = [NSMutableDictionary dictionary];
            [((NSDictionary *)obj) enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                id tmpObject = [self storageObjectWithDictionary:obj];
                if (tmpObject) [mutDictionary setObject:tmpObject forKey:key];
            }];
            returnObject = [NSMutableDictionary dictionaryWithDictionary:mutDictionary];
        }
        else if ([cls isSubclassOfClass:[NSArray class]]) {
            __block NSMutableArray *mutArray = [NSMutableArray array];
            [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id tmpObject = [self storageObjectWithDictionary:obj];
                if (tmpObject) [mutArray addObject:tmpObject];
            }];
            returnObject = [NSMutableArray arrayWithArray:mutArray];
        }
        else if ([cls isSubclassOfClass:[NSNull class]]) {
            returnObject = [NSNull null];
        }
        else if ([cls isSubclassOfClass:[NSObject class]]) {
            NSDictionary *dictionary = [NSJSONSerialization mfscache_objectWithJSONString:obj options:NSJSONReadingAllowFragments error:nil];
            returnObject = [cls objectWithDictionary:dictionary];
        }
        else {
            //TODO:更多的类型
        }
    }];
    return returnObject;
}

- (NSDictionary *)dictionaryWithObject:(id)object {
    //把object转成字符串dictionary，保存方便
    NSString *objectKey = NSStringFromClass([object class]);
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if ([object isKindOfClass:[NSString class]]) {
        [dictionary setValue:object forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSURL class]]) {
        [dictionary setValue:((NSURL *)object).absoluteString forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        [dictionary setValue:((NSNumber *)object).stringValue forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSData class]]) {
        NSString *dataString = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        [dictionary setValue:dataString forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        __block NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [((NSDictionary *)object) enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *objDictionary = [self dictionaryWithObject:obj];
            [objectDictionary setValue:objDictionary forKey:key];
        }];
        [dictionary setValue:objectDictionary forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *objectArray = [NSMutableArray array];
        [((NSArray *)object) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *objDictionary = [self dictionaryWithObject:obj];
            [objectArray addObject:objDictionary];
        }];
        [dictionary setValue:objectArray forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSNull class]]) {
        [dictionary setValue:@"" forKey:objectKey];
    }
    else if ([object isKindOfClass:[NSObject class]]) {
        NSDictionary *dict = [object propertyDictionary];
        NSString *objectString = [NSJSONSerialization mfscache_stringWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        [dictionary setValue:objectString forKey:objectKey];
    }
    else {
        //TODO:更多的类型
    }
    return dictionary;
}

#pragma mark -
- (NSMutableDictionary *)storageOptions {
    return _storageOptions ?: ({ _storageOptions = NSMutableDictionary.new; });
}

- (NSString *)objectIdentifier {
    return _objectIdentifier ?: ({ _objectIdentifier = [self.storageString mfscache_md5]; });
}

- (MFSCacheStorageObjectTimeOutInterval)storageInterval {
    if (self.timeoutInterval > 0) {
        return MFSCacheStorageObjectIntervalTiming;
    }
    else if (self.timeoutInterval < 0) {
        return MFSCacheStorageObjectIntervalAllTime;
    }
    else {
        return MFSCacheStorageObjectIntervalDefault;
    }
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.storageString forKey:@"storageString"];
    [aCoder encodeObject:self.objectIdentifier forKey:@"objectIdentifier"];
    [aCoder encodeObject:@(self.timeoutInterval) forKey:@"timeoutInterval"];
    [aCoder encodeObject:self.storageOptions forKey:@"storageOptions"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.storageString = [aDecoder decodeObjectForKey:@"storageString"];
        self.objectIdentifier = [aDecoder decodeObjectForKey:@"objectIdentifier"];
        self.timeoutInterval = (NSTimeInterval)[[aDecoder decodeObjectForKey:@"timeoutInterval"] doubleValue];
        self.storageOptions = [aDecoder decodeObjectForKey:@"storageOptions"];
    }
    return self;
}

@end
