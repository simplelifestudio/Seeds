//
//  WarningViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "WarningViewController.h"

@interface WarningViewController ()

@end

@implementation WarningViewController

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
    [super viewDidUnload];
}

#pragma mark - IBAtions

- (IBAction)onClickAgreeButton:(id)sender
{
    
}

- (IBAction)onClickDeclineButton:(id)sender
{
    
}

#pragma mark - Private Methods


@end
