//
//  CBAppUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBAppUtils : NSObject

+(void) exitApp;

+(void) asyncProcessInBackgroundThread:(void(^)()) block;
+(void) asyncProcessInMainThread:(void(^)()) block;

@end
