//
//  GUIModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIModule.h"
#import "SplashViewController.h"

@interface GUIModule() <WarningDelegate>
{
    
}

@end

@implementation GUIModule
{
    MBProgressHUD* _HUD;
    
    PAPasscodeViewController* _passcodeViewController;
    BOOL _isLockViewVisible;
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
    _passcodeViewController.passcode = @"1002";
    
    _isLockViewVisible = NO;
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
        _HUD.minSize = HUD_NOTIFICATION_SIZE;
        _HUD.yOffset = HUD_NOTIFICATION_YOFFSET;
        
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

-(WarningViewController*) getWarningViewController:(NSString*) warningId delegate:(id<WarningDelegate>) delegate;
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
    WarningViewController* warningVC = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_WARNINGVIEWCONTROLLER];
    warningVC.warningDelegate = delegate;
    warningVC.warningId = warningId;
    return warningVC;
}

#pragma mark - PAPasscodeViewControllerDelegate

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
        
        _isLockViewVisible = NO;
    }
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts
{
    if (PASSCODE_ATTEMPT_TIMES <= attempts)
    {
        WarningViewController* warningVC = [self getWarningViewController:WARNING_ID_PASSCODEFAILEDATTEMPTS delegate:self];
        
        [_passcodeViewController presentModalViewController:warningVC animated:NO];
        
        [warningVC setAgreeButtonVisible:NO];
        [warningVC setDeclineButtonVisible:NO];
        [warningVC setCountdownSeconds:WARNING_DISPLAY_SECONDS];
        [warningVC setWarningText:NSLocalizedString(@"Passcode failed attempts is too much, app will be terminated once countdown is end.", nil)];
    }
}

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    
}

#pragma mark - UIApplicationDelegate

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    UserDefaultsModule* _userDefaults = [UserDefaultsModule sharedInstance];
    BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
    
    if (isPasscodeSet)
    {
        if (!_isLockViewVisible)
        {
            NSString* passcode = [_userDefaults passcode];
            _passcodeViewController.passcode = passcode;
            
            UIViewController* vc = _homeViewController.presentedViewController;
            if (nil != vc)
            {
                if (vc != _passcodeViewController)
                {
                    [vc presentModalViewController:_passcodeViewController animated:NO];
                    _isLockViewVisible = YES;
                }
            }
            else
            {
                [_homeViewController presentModalViewController:_passcodeViewController animated:NO];
                _isLockViewVisible = YES;
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{

}

#pragma mark - WarningDelegate

-(void) countdownFinished:(NSString*) warningId
{
    [CBAppUtils exitApp];
}

-(void) agreeButtonClicked:(NSString*) warningId
{
    
}

-(void) declineButtonClicked:(NSString*) warningId
{
    
}

#pragma mark - Private Methods

@end
