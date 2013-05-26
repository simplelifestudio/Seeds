//
//  CBSharedInstance.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEFINE_SINGLETON_FOR_HEADER(className) \
//\
//+ (className*) sharedInstance;

#define SINGLETON(className) \
\
+ (id) sharedInstance \
{ \
    static className* sharedInstance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once \
    ( \
        &onceToken, \
        ^ \
        { \
            sharedInstance = [[self alloc] init]; \
        } \
    ); \
    \
    return sharedInstance; \
}

@protocol CBSharedInstance <NSObject>

+(id) sharedInstance;

@end
