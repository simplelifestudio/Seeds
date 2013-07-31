//
//  CrashReportModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-31.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CrashReportModule.h"

#import "CBUncaughtExceptionHandler.h"

@implementation CrashReportModule

+(void)initialize
{
    InstallUncaughtExceptionHandler();
}

SINGLETON(UserDefaultsModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"CrashReport Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"CrashReport Module Thread", nil)];
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
    MODULE_DELAY
}

@end
