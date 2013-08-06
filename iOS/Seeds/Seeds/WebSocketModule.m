//
//  WebSocketModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-6.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "WebSocketModule.h"

@interface WebSocketModule()
{
    
}

@end

@implementation WebSocketModule

SINGLETON(WebSocketModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"WebSocket Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"WebSocket Module Thread", nil)];
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
