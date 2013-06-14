//
//  UserDefaultsModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "UserDefaultsModule.h"

@implementation UserDefaultsModule

SINGLETON(UserDefaultsModule)

@synthesize userDefaults = _userDefaults;

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"UserDefaults Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"UserDefaults Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
}

-(void) releaseModule
{
    [super releaseModule];
}

-(void) startService
{
    DLog(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    MODULE_DELAY
}

-(void) resetDefaults
{
    [self resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
}

-(void) resetDefaultsInPersistentDomain:(NSString*) domain
{
    if (nil != domain && 0 < domain.length)
    {
        [_userDefaults removePersistentDomainForName:domain];
        NSDictionary* newDic = [NSDictionary dictionary];
        [_userDefaults setPersistentDomain:newDic forName:domain];
        DLog(@"UserDefaults in persistent domain: %@ has been reset.", domain);
    }
}

-(NSMutableDictionary*) persistentDomainForName:(NSString*) name
{
    NSMutableDictionary* mutableDic = nil;
    
    if (nil != name && 0 < name.length)
    {
        mutableDic = [NSMutableDictionary dictionary];
        NSDictionary* dic = [_userDefaults persistentDomainForName:name];
        if (nil != dic)
        {
            [mutableDic setDictionary:dic];
        }
    }
    
    return mutableDic;
}

-(void) setValueForKeyInPersistentDomain:(id) value forKey:(NSString*) key inPersistentDomain:(NSString*) domain
{
    NSMutableDictionary* dic = [self persistentDomainForName:domain];
    if (nil != dic)
    {
        [dic setObject:value forKey:key];
        [_userDefaults setPersistentDomain:dic forName:domain];
        [_userDefaults synchronize];
    }
}

-(id) getValueForKeyInPersistentDomain:(NSString*) key inPersistentDomain:(NSString*) domain
{
    id value = nil;
    
    if (nil != domain && 0 < domain.length && nil != key && 0 < key.length)
    {
        NSMutableDictionary* dic = [self persistentDomainForName:domain];
        value = [dic objectForKey:key];
    }
    
    return value;
}

-(BOOL) isThisDaySync:(NSDate*) day
{
    BOOL flag = NO;
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        id value = [self getValueForKeyInPersistentDomain:key inPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        if ([value isEqualToString:@"YES"])
        {
            flag = YES;
        }
    }
    return flag;
}

-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync
{
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        NSString* sVal = (sync) ? @"YES" : @"NO";
        [self setValueForKeyInPersistentDomain:sVal forKey:key inPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
    }
}

-(NSString*) combineKey_syncStatusByDay:(NSDate*) day
{
    if (nil != day)
    {
        NSMutableString* key = [NSMutableString string];
        [key appendString:USERDEFAULTS_KEY_SYNCSTATUSBYDAY];
        NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
        [key appendString:dateStr];
        
        return key;
    }
    
    return nil;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

@end
