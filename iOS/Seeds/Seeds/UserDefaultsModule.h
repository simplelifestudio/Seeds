//
//  UserDefaultsModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

@interface UserDefaultsModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@property (atomic, strong) NSUserDefaults* userDefaults;

#pragma mark - Sync Status
-(BOOL) isThisDaySync:(NSDate*) day;
-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync;

#pragma mark - Passcode
-(BOOL) isPasscodeSet;
-(void) enablePasscodeSet:(BOOL) enabled;
-(NSString*) passcode;
-(void) setPasscode:(NSString*) passcode;

#pragma mark - Network
-(BOOL) isDownloadImagesThrough3GEnabled;
-(void) enableDownloadImagesThrough3G:(BOOL) enabled;

#pragma mark - Common
-(NSMutableDictionary*) persistentDomainForName:(NSString*) name;
-(void) setValueForKeyInPersistentDomain:(id) value forKey:(NSString*) key inPersistentDomain:(NSString*) domain;
-(id) getValueForKeyInPersistentDomain:(NSString*) key inPersistentDomain:(NSString*) domain;
-(void) resetDefaultsInPersistentDomain:(NSString*) domain;
-(void) resetDefaults;

@end
