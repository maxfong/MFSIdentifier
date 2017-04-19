//
//  NSString+MFSIDURLEncoded.h
//  MFSIdentifier
//
//  Created by maxfong on 2017/4/18.
//  Copyright © 2017年 imfong.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MFSIDURLEncoded)

- (NSString *)mfsid_URLEncodedString;
- (NSString *)mfsid_URLDecodedString;

@end
