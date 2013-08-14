//
//  SecurityModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SecurityModule.h"

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
}

@end
