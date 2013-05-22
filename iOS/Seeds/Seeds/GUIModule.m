//
//  GUIModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIModule.h"

@implementation GUIModule

@synthesize homeViewController = _homeViewController;

+(id)sharedInstance
{
    static GUIModule* sharedInstance;
    static dispatch_once_t done;
    dispatch_once
    (
     &done,
     ^
     {
         sharedInstance = [[GUIModule alloc] initWithIsIndividualThreadNecessary:NO];
     }
     );
    return sharedInstance;
}

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"GUI Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"GUI Module Thread", nil)];
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

    // Forbid auto sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void) showHUD:(NSString*) status
{
    if (nil != _homeViewController)
    {
        UIView* view = _homeViewController.navigationController.visibleViewController.view;
        
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:HUD];
        
        HUD.mode = MBProgressHUDModeText;
        HUD.minSize = CGSizeMake(135.f, 135.f);
        
        HUD.labelText = status;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
    }
    else
    {
        DLog(@"No visible view controller registered in GUI module.");
    }
}

@end
