//
//  GUIModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIModule.h"
#import "SplashViewController.h"

@implementation GUIModule
{
    MBProgressHUD* _HUD;
    
    PAPasscodeViewController* _passcodeViewController;
}

@synthesize homeViewController = _homeViewController;

SINGLETON(GUIModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"GUI Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"GUI Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    [self _initPAPasscodeViewController];    
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

-(void) _initPAPasscodeViewController
{
    _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    _passcodeViewController.delegate = self;
    _passcodeViewController.simple = YES;
    _passcodeViewController.passcode = @"8964";
}

-(void) processService
{
#warning Forbid auto sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    MODULE_DELAY    
}

-(void) constructHUD
{
    if (nil == _HUD)
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        //        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
        _HUD = [[MBProgressHUD alloc] initWithWindow:window];
    }
}

-(void) showHUD:(NSString *)status delay:(NSInteger)seconds
{
    [self showHUD:status minorStatus:nil delay:seconds];
}

-(void) showHUD:(NSString*) majorStauts minorStatus:(NSString*) minorStatus delay:(NSInteger)seconds
{
    if (nil != _homeViewController)
    {
        UIView* view = _homeViewController.navigationController.view;

        [self constructHUD];
        [_HUD hide:YES];
        
        [view addSubview:_HUD];
        
        _HUD.mode = MBProgressHUDModeText;
        _HUD.minSize = HUD_SIZE;
        
        _HUD.labelText = majorStauts;
        if (minorStatus)
        {
            _HUD.detailsLabelText = minorStatus;
        }
        else
        {
            _HUD.detailsLabelText = nil;
        }
        
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:seconds];
    }
    else
    {
        DLog(@"No visible view controller registered in GUI module.");
    }
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    UIViewController* vc = _homeViewController.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            // DO NOTHING
        }
        else
        {
            [_homeViewController dismissModalViewControllerAnimated:NO];
        }
    }
    else
    {
        // DO NOTHING
    }
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    UIViewController* vc = _homeViewController.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            [vc dismissModalViewControllerAnimated:NO];
        }
        else
        {
            [_homeViewController dismissModalViewControllerAnimated:NO];
        }
    }
    else
    {
        [_homeViewController presentModalViewController:_passcodeViewController animated:NO];
    }
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    // TODO: Update passcode(controller.passcode) into user defaults module
    _passcodeViewController.passcode = controller.passcode;    
    
    UIViewController* vc = _homeViewController.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            // DO NOTHING
        }
        else
        {
            [_homeViewController dismissModalViewControllerAnimated:NO];
        }
    }
    else
    {
        // DO NOTHING
    }
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
    // TODO: Update passcode(controller.passcode) into user defaults module    
    _passcodeViewController.passcode = controller.passcode;
    
    UIViewController* vc = _homeViewController.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            // DO NOTHING
        }
        else
        {
            [_homeViewController dismissModalViewControllerAnimated:NO];
        }
    }
    else
    {
        // DO NOTHING
    }
}

#pragma mark - UIApplicationDelegate

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
    UIViewController* vc = _homeViewController.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            [vc presentModalViewController:_passcodeViewController animated:NO];
        }
        else
        {
            // DO NOTHING
        }
    }
    else
    {
        [_homeViewController presentModalViewController:_passcodeViewController animated:NO];
    }
}

@end
