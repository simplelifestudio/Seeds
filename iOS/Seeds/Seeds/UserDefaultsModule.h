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

#define PERSISTENTDOMAIN_SYNCSTATUSBYDAY @"syncStatusByDay"

@interface UserDefaultsModule : CBModuleAbstractImpl <CBSharedInstance>

@property (atomic, strong) NSUserDefaults* userDefaults;

-(void) resetDefaults;

-(BOOL) isThisDaySync:(NSDate*) day;
-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync;

-(NSMutableDictionary*) persistentDomainForName:(NSString*) name;
-(void) setValueForKeyInPersistentDomain:(id) value forKey:(NSString*) key inPersistentDomain:(NSString*) domain;
-(id) getValueForKeyInPersistentDomain:(NSString*) key inPersistentDomain:(NSString*) domain;
-(void) resetDefaultsInPersistentDomain:(NSString*) domain;

@end
