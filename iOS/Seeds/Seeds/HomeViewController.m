//
//  HomeViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
{
    MBProgressHUD* HUD;
    
    UIBarButtonItem* backBarItem;
    UIBarButtonItem* stopBarItem;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    backBarItem = self.navigationItem.backBarButtonItem;
    stopBarItem = [[UIBarButtonItem alloc] init];
    stopBarItem.title = NSLocalizedString(@"Stop", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setSyncButton:nil];
    [self setTransButton:nil];
    [super viewDidUnload];
}

- (IBAction)onClickSyncButton:(id)sender
{
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;

	[HUD showWhileExecuting:@selector(syncSeedsInfoTask) onTarget:self withObject:nil animated:YES];
}

- (void)syncSeedsInfoTask
{
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider pullSeedsInfo:HUD];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_ID_HOME2TRANSMIT])
    {
        backBarItem = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = stopBarItem;
    }
    else
    {
        self.navigationItem.backBarButtonItem = backBarItem;
    }
}

@end
