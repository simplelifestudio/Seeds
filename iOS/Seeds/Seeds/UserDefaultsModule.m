//
//  UserDefaultsModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "UserDefaultsModule.h"

@implementation UserDefaultsModule

+(id)sharedInstance
{
    static UserDefaultsModule* sharedInstance;
    static dispatch_once_t done;
    dispatch_once
    (
        &done,
        ^
        {
            sharedInstance = [[UserDefaultsModule alloc] initWithIsIndividualThreadNecessary:NO];
        }
    );
    return sharedInstance;
}

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
    [NSThread sleepForTimeInterval:0.5];
}

-(void) resetDefaults
{
    [_userDefaults removePersistentDomainForName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
    [_userDefaults setPersistentDomain:[NSDictionary dictionary] forName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
    DLog(@"UserDefaults has been reset.")
}

-(BOOL) isThisDaySync:(NSDate*) day
{
    BOOL flag = NO;
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        
        NSDictionary* dic = [_userDefaults persistentDomainForName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        if (nil == dic)
        {
            dic = [NSMutableDictionary dictionaryWithObject:(flag ? @"YES" : @"NO") forKey:key];
            [_userDefaults setPersistentDomain:dic forName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
            [_userDefaults synchronize];
        }
        else
        {
            id obj = [dic objectForKey:key];
            if ([obj isEqualToString:@"YES"])
            {
                flag = YES;
            }
        }
    }
    return flag;
}

-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync
{
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        NSDictionary* dic = [_userDefaults persistentDomainForName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        if (nil == dic)
        {
            dic = [NSMutableDictionary dictionary];
        }
        dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        [dic setValue:sync ? @"YES" : @"NO" forKey:key];
        [_userDefaults setPersistentDomain:dic forName:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        [_userDefaults synchronize];
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

@end
