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

SINGLETON(SpiderModule)

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
    DDLogVerbose(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    MODULE_DELAY
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

@end
