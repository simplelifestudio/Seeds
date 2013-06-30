//
//  NSDictionary+JSON.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

// 直把远程的地址上JSON数据转换成Dictionary对象
+(NSDictionary*) dictionaryWithContentsOfURLString:(NSString*)urlAddress;

// 把当前的Dictionary对象转成JSON对象
-(NSData*) toJSON;

@end