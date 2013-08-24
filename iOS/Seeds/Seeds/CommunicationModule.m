//
//  CommunicationModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CommunicationModule.h"

#import "GUIModule.h"

#import "Reachability.h"
#import "MBProgressHUD.h"

#define _HUD_DISPLAY 1

@interface CommunicationModule()
{

}

@end

@implementation CommunicationModule

SINGLETON(CommunicationModule)

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

- (void)registerReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability* hostReach = [Reachability reachabilityWithHostname:RACHABILITY_HOST];
    [hostReach startNotifier];    
}

- (void) unregisterReachability
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    [curReach connectionRequired];

    GUIModule* guiModule = [GUIModule sharedInstance];
    
    switch (status)
    {
        case NotReachable:
        {
            [guiModule showHUD:NSLocalizedString(@"Internet Disconnected", nil) delay:_HUD_DISPLAY];
            
            DDLogWarn(@"App's reachability changed to 'NotReachable'.");
            break;
        }
        case ReachableViaWiFi:
        {
            [guiModule showHUD:NSLocalizedString(@"WiFi Connected", nil) delay:_HUD_DISPLAY];
            
            DDLogWarn(@"App's reachability changed to 'ReachableViaWiFi'.");
            break;
        }
        case ReachableViaWWAN:
        {
            [guiModule showHUD:NSLocalizedString(@"3G/GPRS Connected", nil) delay:_HUD_DISPLAY];
            
            DDLogWarn(@"App's reachability changed to 'ReachableViaWWAN'.");
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) releaseModule
{
    [self unregisterReachability];
    
    [_serverAgent.pictureAgent saveThumbnailCacheKeys];
    
    [self setSpider:nil];
    [self setServerAgent:nil];
    
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
    
    [self registerReachability];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        [_serverAgent.pictureAgent clearMemory];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{

}

@end
