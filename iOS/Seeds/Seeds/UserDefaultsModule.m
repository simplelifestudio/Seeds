//
//  UserDefaultsModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-8.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "UserDefaultsModule.h"

@implementation UserDefaultsModule

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
    [NSThread sleepForTimeInterval:1.0];
}

@end
