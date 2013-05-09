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

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"UserDefaults Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"UserDefaults Module Thread", nil)];
    [self setKeepAlive:FALSE];
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

-(BOOL) isThisDaySync:(NSDate*) day
{
    BOOL flag = NO;
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        flag = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
    return flag;
}

-(void) setThisDaySync:(NSDate*) day sync:(BOOL) sync
{
    if (nil != day)
    {
        NSString* key = [self combineKey_syncStatusByDay:day];
        [[NSUserDefaults standardUserDefaults] setBool:sync forKey:key];
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
