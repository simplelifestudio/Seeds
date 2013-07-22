//
//  SplashViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SplashViewController.h"

#import "UIDevice+Resolutions.h"

#import "WarningViewController.h"

@interface SplashViewController () <WarningDelegate>
{
    UserDefaultsModule* _userDefaults;
    GUIModule* _guiModule;
    
    PAPasscodeViewController* _passcodeViewController;
}

@property (nonatomic, strong) NSThread *loadStuffThread;

@end

@implementation SplashViewController

@synthesize progressLabel;
@synthesize progressView;
@synthesize loadStuffThread = _loadStuffThread;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self _setupViewController];
}

- (void)viewDidUnload
{
    [self setLoadStuffThread:nil];
    [self setProgressLabel:nil];
    [self setProgressView:nil];
    
    [super viewDidUnload];
}

- (void)startFadingSplashScreen
{
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishFadingSplashScreen)];   // calls the finishFadingSplashScreen method when the animation is done (or done fading out)
	self.view.alpha = 0.0;       // Fades the alpha channel of this view to "0.0" over the animationDuration of "0.75" seconds
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}

- (void) finishFadingSplashScreen
{
    if (![UIDevice isRunningOniPhone5])
    {
        WarningViewController* warningVC = [_guiModule getWarningViewController:WARNING_ID_UNSUPPORTDEVICES delegate:self];
        
        [self presentModalViewController:warningVC animated:NO];
        
        [warningVC setAgreeButtonVisible:NO];
        [warningVC setDeclineButtonVisible:NO];
        [warningVC setCountdownSeconds:WARNING_DISPLAY_SECONDS];
        [warningVC setWarningText:NSLocalizedString(@"Warning of Unsupported Devices", nil)];
        
        return;
    }
    
    BOOL appLaunchedBefore = [_userDefaults isAppLaunchedBefore];
    if (appLaunchedBefore)
    {
        [self _enterInApp];
    }
    else
    {
        WarningViewController* warningVC = [_guiModule getWarningViewController:WARNING_ID_APPFIRSTLAUNCHED delegate:self];
        
        [self presentModalViewController:warningVC animated:NO];
        
        [warningVC setCountdownSeconds:WARNING_DISPLAY_SECONDS * 2];
        [warningVC setWarningText:NSLocalizedString(@"Warning of App First Launched", nil)];
    }
}

- (void) loadAnyNecessaryStuff
{
    // All CBModules should start here
    
    CBModuleManager* moduleManager = [CBModuleManager sharedInstance];
    NSArray* moduleList = [moduleManager moduleList];
    float percents = 0;
    for (id<CBModule> module in moduleList)
    {
        percents = percents + module.moduleWeightFactor;
        percents = (1 < percents) ? 1 : percents;
        [module initModule];
        [self updateProgress:module.moduleIdentity andPercents:percents];
        [module startService];
    }
    
    // Switch back to Splash UI
    [self performSelectorOnMainThread:@selector(startFadingSplashScreen) withObject:self waitUntilDone:YES];
}

-(void) updateProgress:(NSString*) text andPercents:(float) percents
{
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate distantPast]];
    [self performSelectorOnMainThread:@selector(updateProgressText:) withObject:text waitUntilDone:NO];
    NSNumber *percentsVal = [NSNumber numberWithFloat:percents];
    [self performSelectorOnMainThread:@selector(updateProgressPercents:) withObject:percentsVal waitUntilDone:NO];
}

-(void) updateProgressText:(NSString*) text
{
    if ([self.progressLabel isHidden])
    {
        [self.progressLabel setHidden:FALSE];
    }
    
    NSMutableString* str = [NSMutableString stringWithString:NSLocalizedString(@"Loading: ", nil)];
    text = (nil != text) ? text : @"";
    [str appendString:text];
    
    [self.progressLabel setText:str];
}

-(void) updateProgressPercents:(NSNumber*) percentsVal
{
    if ([self.progressView isHidden])
    {
        [self.progressView setHidden:FALSE];
    }
    
    [self.progressView setProgress:percentsVal.floatValue animated:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    UIViewController* vc = self.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            [vc dismissModalViewControllerAnimated:NO];
        }
        else
        {
            [self dismissModalViewControllerAnimated:NO];
            
            BOOL isAppLaunchedBefore = [_userDefaults isAppLaunchedBefore];
            
            if (!isAppLaunchedBefore)
            {
                [self performSegueWithIdentifier:SEGUE_ID_SPLASH2HELP sender:self];
            }
            else
            {
                [self performSegueWithIdentifier:SEGUE_ID_SPLASH2NAVIGATION sender:self];
            }
        }
    }
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    _passcodeViewController.passcode = controller.passcode;

    [_userDefaults setPasscode:_passcodeViewController.passcode];
    
    UIViewController* vc = self.presentedViewController;
    if (nil != vc)
    {
        if (vc != _passcodeViewController)
        {
            // DO NOTHING
        }
        else
        {
            [self dismissModalViewControllerAnimated:NO];
            
            BOOL isAppLaunchedBefore = [_userDefaults isAppLaunchedBefore];
            
            if (!isAppLaunchedBefore)
            {
                [self performSegueWithIdentifier:SEGUE_ID_SPLASH2HELP sender:self];
            }
            else
            {
                [self performSegueWithIdentifier:SEGUE_ID_SPLASH2NAVIGATION sender:self];
            }
        }
    }
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts
{
    if (PASSCODE_ATTEMPT_TIMES <= attempts)
    {
        WarningViewController* warningVC = [_guiModule getWarningViewController:WARNING_ID_PASSCODEFAILEDATTEMPTS delegate:self];
        
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

#pragma mark - WarningDelegate

-(void) countdownFinished:(NSString*) warningId
{
    [CBAppUtils exitApp];
}

-(void) agreeButtonClicked:(NSString*) warningId
{
    [self _enterInApp];
}

-(void) declineButtonClicked:(NSString*) warningId
{
    [CBAppUtils exitApp];
}

#pragma mark - Private Methods

-(void) _setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    _guiModule = [GUIModule sharedInstance];
    
    _loadStuffThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadAnyNecessaryStuff)  object:nil];
    [_loadStuffThread start];
}

- (void) _enterInApp
{
    BOOL appLaunchedBefore = [_userDefaults isAppLaunchedBefore];
    if (!appLaunchedBefore)
    {
        [self dismissModalViewControllerAnimated:NO];
        
        _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
        
        _passcodeViewController.delegate = self;
        _passcodeViewController.simple = YES;
        [self presentModalViewController:_passcodeViewController animated:NO];
    }
    else
    {
        BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
        if (isPasscodeSet)
        {
            NSString* passcode = [_userDefaults passcode];
            
            _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
            _passcodeViewController.passcode = passcode;
            
            _passcodeViewController.delegate = self;
            _passcodeViewController.simple = YES;
            
            [self presentModalViewController:_passcodeViewController animated:NO];
        }
        else
        {
            [self dismissModalViewControllerAnimated:NO];
            [self performSegueWithIdentifier:SEGUE_ID_SPLASH2NAVIGATION sender:self];
        }
    }
}

@end
