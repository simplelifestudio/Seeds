//
//  AppDelegate.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize moduleManager = _moduleManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Modules initialization
    _moduleManager = [CBModuleManager sharedInstance];
    
//    id<CBModule> crashReportModule = [CrashReportModule sharedInstance];
//    crashReportModule.moduleWeightFactor = 0.1;
//    [_moduleManager registerModule:crashReportModule];
    
    id<CBModule> loggerModule = [LoggerModule sharedInstance];
    loggerModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:loggerModule];
    
    id<CBModule> databaseModule = [DatabaseModule sharedInstance];
    databaseModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:databaseModule];
    
    id<CBModule> userDefaultModule = [UserDefaultsModule sharedInstance];
    userDefaultModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:userDefaultModule];
    
    id<CBModule> communicationModule = [CommunicationModule sharedInstance];
    communicationModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:communicationModule];
    
    id<CBModule> webSocketModule = [WebSocketModule sharedInstance];
    webSocketModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:webSocketModule];
    
    id<CBModule> spiderModule = [SpiderModule sharedInstance];
    spiderModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:spiderModule];
    
    id<CBModule> transmissionModule = [TransmissionModule sharedInstance];
    transmissionModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:transmissionModule];
    
    id<CBModule> guiModule = [GUIModule sharedInstance];
    guiModule.moduleWeightFactor = 0.2;
    [_moduleManager registerModule:guiModule];
    
    id<CBModule> securityModule = [SecurityModule sharedInstance];
    securityModule.moduleWeightFactor = 0.1;
    [_moduleManager registerModule:securityModule];
    
    DDLogVerbose(@"App Sandbox Path: %@", NSHomeDirectory());    
    
    [Crashlytics startWithAPIKey:@"592220da47f22b9cdb4a9df47ea79170d94a150a"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [_moduleManager applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [_moduleManager applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [_moduleManager applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_moduleManager applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [_moduleManager applicationWillTerminate:application];
}

@end
