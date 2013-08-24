//
//  SecurityModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SecurityModule.h"

#import "CBSecurityUtils.h"

#import "SSKeychain.h"

@implementation SecurityModule

SINGLETON(UserDefaultsModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Security Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Security Module Thread", nil)];
    [self setKeepAlive:FALSE];
}

-(void) releaseModule
{
    [super releaseModule];
}

-(void) startService
{
    DDLogVerbose(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    MODULE_DELAY
    
    NSString* idfv = [SSKeychain passwordForService:KEYCHAIN_SERVICE_DEVICE account:KEYCHAIN_ACCOUNT_IDFV];
    if (nil == idfv)
    {
        idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:idfv forService:KEYCHAIN_SERVICE_DEVICE account:KEYCHAIN_ACCOUNT_IDFV];
    }
    DDLogCInfo(@"Device Unique Identifier for Vendor: %@", idfv);
    
    UIDevice* device = [UIDevice currentDevice];
    DDLogCInfo(@"Device Model: %@", [UIDevice deviceModel]);
    DDLogCInfo(@"System Name: %@", device.systemName);
    DDLogCInfo(@"System Version: %@", device.systemVersion);
}

@end
