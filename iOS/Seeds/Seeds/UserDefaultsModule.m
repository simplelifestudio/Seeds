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

#pragma mark - Common

-(void) resetDefaults
{
    [self resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
    [self resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_PASSCODE];
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

-(NSString*) combineKey_syncStatusByDay:(NSDate*) day
{
    if (nil != day)
    {
        NSMutableString* key = [NSMutableString string];
        [key appendString:USERDEFAULTS_KEY_SYNCSTATUSBYDAY];
        NSString* dateStr = [CBDateUtils shortDateString:day];
        [key appendString:dateStr];
        
        return key;
    }
    
    return nil;
}

#pragma mark - Sync Status

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

#pragma mark - Passcode

-(BOOL) isPasscodeSet
{
    BOOL flag = NO;
    
    id value = [self getValueForKeyInPersistentDomain:USERDEFAULTS_KEY_PASSCODESET inPersistentDomain:PERSISTENTDOMAIN_PASSCODE];
    if ([value isEqualToString:@"YES"])
    {
        flag = YES;
    }
    
    return flag;
}

-(void) enablePasscodeSet:(BOOL) enabled
{
    NSString* sVal = (enabled) ? @"YES" : @"NO";
    [self setValueForKeyInPersistentDomain:sVal forKey:USERDEFAULTS_KEY_PASSCODESET inPersistentDomain:PERSISTENTDOMAIN_PASSCODE];
}

-(NSString*) passcode
{
    NSString* passcode = nil;
    
    BOOL isPasscodeSet = [self isPasscodeSet];
    if (isPasscodeSet)
    {
        id value = [self getValueForKeyInPersistentDomain:USERDEFAULTS_KEY_PASSCODE inPersistentDomain:PERSISTENTDOMAIN_PASSCODE];
        passcode = (NSString*) value;
    }
    
    return passcode;
}

-(void) setPasscode:(NSString*) passcode
{
    if (nil != passcode && 0 < passcode.length)
    {
        [self enablePasscodeSet:YES];
        [self setValueForKeyInPersistentDomain:passcode forKey:USERDEFAULTS_KEY_PASSCODE inPersistentDomain:PERSISTENTDOMAIN_PASSCODE];
    }
}

#pragma mark - Network
-(BOOL) isDownloadImagesThrough3GEnabled
{
    BOOL flag = NO;
    
    id value = [self getValueForKeyInPersistentDomain:USERDEFAULTS_KEY_3GDOWNLOADIMAGES inPersistentDomain:PERSISTENTDOMAIN_NETWORK];
    if ([value isEqualToString:@"YES"])
    {
        flag = YES;
    }
    
    return flag;
}

-(void) enableDownloadImagesThrough3G:(BOOL) enabled
{
    NSString* sVal = (enabled) ? @"YES" : @"NO";
    [self setValueForKeyInPersistentDomain:sVal forKey:USERDEFAULTS_KEY_3GDOWNLOADIMAGES inPersistentDomain:PERSISTENTDOMAIN_NETWORK];
}

#pragma mark - ApplicationDelegate

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
