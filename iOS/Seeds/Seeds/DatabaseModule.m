//
//  DatabaseModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "DatabaseModule.h"

@implementation DatabaseModule

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Database Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Database Module Thread", nil)];
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
