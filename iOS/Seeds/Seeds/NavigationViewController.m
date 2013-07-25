//
//  NavigationViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-25.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()
{
    UserDefaultsModule* _userDefaults;
    GUIModule* _guiModule;
}

@end

@implementation NavigationViewController

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
    [self _setupViewController];
    
    [self _arrangeRootViewController];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

-(void) _setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    _guiModule = [GUIModule sharedInstance];
}

-(void) _arrangeRootViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
    
    BOOL isAppLaunchedBefore = [_userDefaults isAppLaunchedBefore];
    if (!isAppLaunchedBefore)
    {
        HelpViewController* helpVC = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_HELPVIEWCONTROLLER];
        _guiModule.helpViewController = helpVC;
        [self pushViewController:helpVC animated:YES];
    }
    else
    {        
        [self pushViewController:_guiModule.homeViewController animated:YES];
    }
}

@end
