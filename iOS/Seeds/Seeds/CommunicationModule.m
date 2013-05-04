//
//  CommunicationModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CommunicationModule.h"

@implementation CommunicationModule

@synthesize spider = _spider;
@synthesize serverAgent = _serverAgent;

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Communication Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Communication Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _spider = [[SeedsSpider alloc] init];
    _serverAgent = [[ServerAgent alloc] init];
}

-(void) releaseModule
{
    [self setSpider:nil];
    [self setServerAgent:nil];
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
