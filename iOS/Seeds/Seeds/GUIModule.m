//
//  GUIModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIModule.h"

@implementation GUIModule
{
    MBProgressHUD* HUD;
}

@synthesize homeViewController = _homeViewController;

SINGLETON(GUIModule)

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
    // Forbid auto sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    MODULE_DELAY    
}

-(void) constructHUD
{
    if (nil == HUD)
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        //        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
        HUD = [[MBProgressHUD alloc] initWithWindow:window];
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
//        UIView* view = _homeViewController.navigationController.visibleViewController.view;
        UIView* view = _homeViewController.navigationController.view;

        [self constructHUD];
        [HUD hide:YES];
        
        [view addSubview:HUD];
        
        HUD.mode = MBProgressHUDModeText;
        HUD.minSize = HUD_SIZE;
        
        HUD.labelText = majorStauts;
        if (minorStatus)
        {
            HUD.detailsLabelText = minorStatus;
        }
        else
        {
            HUD.detailsLabelText = nil;
        }
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:seconds];
    }
    else
    {
        DLog(@"No visible view controller registered in GUI module.");
    }
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
//    [self dismissViewControllerAnimated:YES completion:^() {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
//    [self dismissViewControllerAnimated:YES completion:^() {
//        _passcodeLabel.text = controller.passcode;
//    }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
//    [self dismissViewControllerAnimated:YES completion:^() {
//        _passcodeLabel.text = controller.passcode;
//    }];
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
    
}

@end
