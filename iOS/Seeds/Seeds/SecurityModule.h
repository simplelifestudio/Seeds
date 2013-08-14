//
//  SecurityModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

@interface SecurityModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@end
