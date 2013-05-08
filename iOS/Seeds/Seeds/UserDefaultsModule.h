//
//  UserDefaultsModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

#define USERDEFAULTS_KEY_SYNCSTATUSBYDAY @"syncStatusByDay:"

@interface UserDefaultsModule : CBModuleAbstractImpl <CBSharedInstance>

-(BOOL) isThisDaySync:(NSDate*) day;
-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync;

@end
