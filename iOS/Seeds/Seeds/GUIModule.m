//
//  GUIModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIModule.h"

#import "CBHUDAgent.h"

#import "SplashViewController.h"

@interface GUIModule() <WarningDelegate>
{
    AFNetworkActivityIndicatorManager* _networkActivityIndicator;
    BOOL _isPasscodeVCVisible;
}

@end

@implementation GUIModule
{
    PAPasscodeViewController* _passcodeViewController;
}

@synthesize homeViewController = _homeViewController;
@synthesize helpViewController = _helpViewController;
@synthesize HUDAgent = _HUDAgent;

SINGLETON(GUIModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"GUI Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"GUI Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _isPasscodeVCVisible = NO;
    
    _networkActivityIndicator = [AFNetworkActivityIndicatorManager sharedManager];    
    
    [self _initPAPasscodeViewController];
}

-(void) releaseModule
{
    [_HUDAgent releaseResources];
    
    [super releaseModule];
}

-(void) startService
{
    DLog(@"Module:%@ is started.", self.moduleIdentity);
        
    [super startService];
    
    [_networkActivityIndicator setEnabled:YES];
}

-(void) _initPAPasscodeViewController
{
    _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    _passcodeViewController.delegate = self;
    _passcodeViewController.simple = YES;
}

-(void) processService
{
#warning Forbid auto sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    MODULE_DELAY    
}

-(void) setHomeViewController:(HomeViewController *)homeViewController
{
    _homeViewController = homeViewController;
    _helpViewController = nil;
}

-(HomeViewController*) homeViewController
{
    if (nil == _homeViewController)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
        _homeViewController = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_HOMEVIEWCONTROLLER];
    }
    
    return _homeViewController;
}

-(CBHUDAgent*) HUDAgent
{
    if ((nil == _HUDAgent) && (nil != _homeViewController))
    {
        UIView* view = _homeViewController.navigationController.view;
        _HUDAgent = [[CBHUDAgent alloc] initWithUIView:view];
    }
    
    return _HUDAgent;
}

-(void) showHUD:(NSString *)status delay:(NSInteger)seconds
{
    [self showHUD:status minorStatus:nil delay:seconds];
}

-(void) showHUD:(NSString*) majorStauts minorStatus:(NSString*) minorStatus delay:(NSInteger)seconds
{
    [self.HUDAgent showHUD:majorStauts minorStatus:minorStatus delay:seconds];
}

-(WarningViewController*) getWarningViewController:(NSString*) warningId delegate:(id<WarningDelegate>) delegate;
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
    WarningViewController* warningVC = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_WARNINGVIEWCONTROLLER];
    warningVC.warningDelegate = delegate;
    warningVC.warningId = warningId;
    return warningVC;
}

- (BOOL) isNetworkActivityIndicatorVisible
{
    BOOL flag = [UIApplication sharedApplication].networkActivityIndicatorVisible;
    
    return flag;
}

- (void) setNetworkActivityIndicatorVisible:(BOOL) flag
{
    if ((flag != [self isNetworkActivityIndicatorVisible]) && (![_networkActivityIndicator isNetworkActivityIndicatorVisible]))
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = flag;
    }
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    [self _showPasscodeViewController:NO];
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts
{
    if (PASSCODE_ATTEMPT_TIMES <= attempts)
    {
        WarningViewController* warningVC = [self getWarningViewController:WARNING_ID_PASSCODEFAILEDATTEMPTS delegate:self];
        
        [_passcodeViewController presentViewController:warningVC animated:NO completion:nil];
        
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
        NSString* passcode = [_userDefaults passcode];
        _passcodeViewController.passcode = passcode;
        
        [self _showPasscodeViewController:YES];
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

-(UIViewController*) _currentRootViewController
{
    UIViewController* rootVC = (nil != _homeViewController) ? _homeViewController : _helpViewController;
    return rootVC;
}

-(void) _showPasscodeViewController:(BOOL) visible
{
    UIViewController* rootVC = [self _currentRootViewController];
    
    if (rootVC)
    {        
        if (visible)
        {
            if (!_isPasscodeVCVisible)
            {
                UIViewController* vc = rootVC.presentedViewController;
                if (nil != vc)
                {
                    [vc presentViewController:_passcodeViewController animated:NO completion:nil];
                }
                else
                {
                    [rootVC presentViewController:_passcodeViewController animated:NO completion:nil];
                }
                
                _isPasscodeVCVisible = YES;
            }
        }
        else
        {
            if (_isPasscodeVCVisible)
            {
                [_passcodeViewController dismissViewControllerAnimated:NO completion:nil];
                _isPasscodeVCVisible = NO;
            }
        }
    }
}

@end
