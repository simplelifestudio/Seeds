//
//  CrashReportModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-31.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

@interface CrashReportModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@end
