//
//  TransmitModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmissionModule.h"

@implementation TransmissionModule

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Transmission Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Transmission Module Thread", nil)];
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

@end
