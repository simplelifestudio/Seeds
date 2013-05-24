//
//  CBModuleManager.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleManager.h"

@interface CBModuleManager()
{
    NSMutableArray* moduleList;
}

@end

@implementation CBModuleManager

SINGLETON(CBModuleManager)

-(id) init
{
    self = [super init];
    if (self)
    {
        moduleList = [NSMutableArray array];
    }
    return self;
}

-(void) registerModule:(id<CBModule>) module
{
    if (nil != module)
    {
        [moduleList addObject:module];
    }
}

-(void) unregistModule:(id<CBModule>) module
{
    if (nil != module)
    {
        for (id<CBModule> m in moduleList)
        {
            if (module == m)
            {
                [moduleList removeObject:m];
                break;
            }
        }
    }
}

-(void) initModules
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m initModule];
        }
    }
}

-(void) startModuleServices
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m startService];
        }
    }
}

-(void) processModuleServices
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m processService];
        }
    }
}

-(void) pauseModuleServices
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m pauseService];
        }
    }
}

-(void) stopModuleServices
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m stopService];
        }
    }
}

-(void) releaseModules
{
    for (id<CBModule> m in moduleList)
    {
        if (nil != m)
        {
            [m releaseModule];
        }
    }
}

-(NSArray*) moduleList
{
    NSMutableArray* copyArray = [NSMutableArray arrayWithArray:moduleList];
    
    return copyArray;
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

-(void)applicationWillTerminate:(UIApplication *)application
{
    [self releaseModules];
}

@end
