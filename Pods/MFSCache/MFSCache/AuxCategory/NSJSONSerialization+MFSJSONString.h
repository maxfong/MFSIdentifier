//
//  NSJSONSerialization+MFSJSONString.h
//  MFSNetworkEngine
//
//  Created by maxfong on 15/7/7.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  https://github.com/maxfong/MFSCache

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (MFSJSONString)

/* Generate JSON string from a Foundation object. If the object will not produce valid JSON then an exception will be thrown. Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting string is a encoded in UTF-8.
 */
+ (NSString *)mfscache_stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

/* Create a Foundation object from JSON string. Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary. Setting the NSJSONReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries. Setting the NSJSONReadingMutableLeaves option will make the parser generate mutable NSString objects. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
 The string must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The string may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the string passed to this method, use UTF-8.
 */
+ (id)mfscache_objectWithJSONString:(NSString *)string options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end
