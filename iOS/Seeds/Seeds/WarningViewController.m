//
//  WarningViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "WarningViewController.h"

@interface WarningViewController ()
{
    
}

@end

@implementation WarningViewController

@synthesize warningTextView = _warningTextView;
@synthesize countdownLabel = _countdownLabel;
@synthesize agreeButton = _agreeButton;
@synthesize declineButton = _declineButton;
@synthesize warningNavigationItem = _warningNavigationItem;

@synthesize warningDelegate = _warningDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self _setupViewController];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [self _setupViewController];    
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setWarningTextView:nil];
    [self setCountdownLabel:nil];
    [self setAgreeButton:nil];
    [self setDeclineButton:nil];
    [self setWarningNavigationItem:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    
    
    [super viewWillAppear:animated];
}

- (void) setWarningText:(NSString*) text
{
    [_warningTextView setText:text];
}

- (void) setCountdownSeconds:(NSUInteger) seconds
{
    if (0 < seconds)
    {        
        
        
        if (_warningDelegate)
        {
//            [_warningDelegate countdownFinished];
        }
    }
}

- (void) setAgreeButtonVisible:(BOOL) visible
{
    [_agreeButton setHidden:!visible];
}

- (void) setDeclineButtonVisible:(BOOL) visible
{
    [_declineButton setHidden:!visible];
}

#pragma mark - IBAtions

- (IBAction)onClickAgreeButton:(id)sender
{
    
}

- (IBAction)onClickDeclineButton:(id)sender
{
    
}

#pragma mark - Private Methods

- (void) _setupViewController
{
    
}

@end
