//
//  MFSJSONEntityPropertyProtocol.h
//  MFSJSONEntity
//
//  Created by maxfong on 15/12/14.
//  Copyright © 2015年 MFS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MFSJSONEntityPropertyProtocol <NSObject>

@optional
/** 获取到指定父类的属性列表 */
- (Class)ownPropertysUntilClass;

@end
