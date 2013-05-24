//
//  SpiderModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SpiderModule.h"

@implementation SpiderModule

@synthesize spider = _spider;

DEFINE_SINGLETON_FOR_CLASS(SpiderModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Spider Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Spider Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _spider = [[SeedsSpider alloc] init];
}

-(void) releaseModule
{
    [self setSpider:nil];

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
