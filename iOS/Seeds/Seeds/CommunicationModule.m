//
//  CommunicationModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CommunicationModule.h"

@implementation CommunicationModule

-(void) initModule
{
    [self setModuleIdentity:@"Communication Module"];
    [self.serviceThread setName:@"Communication Module Thread"];
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
