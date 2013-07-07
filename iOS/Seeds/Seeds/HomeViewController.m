//
//  HomeViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "HomeViewController.h"

#import "SpiderModule.h"
#import "GUIModule.h"

#import "SeedListViewController.h"

@interface HomeViewController ()
{
    MBProgressHUD* HUD;
    
    UIBarButtonItem* backBarItem;
    UIBarButtonItem* stopBarItem;
    
    NSArray* last3Days;
}
@end

@implementation HomeViewController

@synthesize todaySyncStatusLabel = _todaySyncStatusLabel;
@synthesize yesterdaySyncStatusLabel = _yesterdaySyncStatusLabel;
@synthesize theDayBeforeSyncStatusLabel = _theDayBeforeSyncStatusLabel;

@synthesize todayButton = _todayButton;
@synthesize yesterdayButton = _yesterdayButton;
@synthesize theDayBeforeButton = _theDayBeforeButton;

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
    
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider setSeedsSpiderDelegate:self];

    CommunicationModule* communicationModule = [CommunicationModule sharedInstance];
    ServerAgent* serverAgent = communicationModule.serverAgent;
    serverAgent.delegate = self;
    
    GUIModule* guiModule = [GUIModule sharedInstance];
    guiModule.homeViewController = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) _appDidEnterBackground
{

}

- (void) _appDidBecomeActive
{
    [self updateDayAndSyncStatusLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    [self updateDayAndSyncStatusLabels];

    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setSyncButton:nil];
    [self setTransButton:nil];

    [self setTodayLabel:nil];
    [self setYesterdayLabel:nil];
    [self setTheDayBeforeLabel:nil];
    [self setTodaySyncStatusLabel:nil];
    [self setYesterdaySyncStatusLabel:nil];
    [self setTheDayBeforeSyncStatusLabel:nil];
    [self setTodayButton:nil];
    [self setYesterdayButton:nil];
    [self setTheDayBeforeButton:nil];

    [super viewDidUnload];
}

- (IBAction)onClickSyncButton:(id)sender
{    
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;
    
	[HUD showWhileExecuting:@selector(syncSeedsInfoTask) onTarget:self withObject:nil animated:YES];
}

-(void) updateHUDTextStatus:(NSString*) majorStatus minorStatus:(NSString*)minorStatus
{
    if (nil != majorStatus && 0 < majorStatus.length)
    {
        HUD.labelText = majorStatus;
    }
    
    HUD.detailsLabelText = minorStatus;
}

- (void)syncSeedsInfoTask
{
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider pullSeedsInfo:last3Days];

//    CommunicationModule* communicationModule = [CommunicationModule sharedInstance];
//    ServerAgent* serverAgent = communicationModule.serverAgent;
//    [serverAgent syncSeedsInfo];
}

- (void) updateDayLabel:(NSDate*) day dayIndex:(DayIndex) dayIndex;
{
    NSString* dateStr = [CBDateUtils shortDateString:day];
    switch (dayIndex)
    {
        case Today:
        {
            [_todayLabel setText:dateStr];
            break;
        }
        case Yesterday:
        {
            [_yesterdayLabel setText:dateStr];
            break;
        }
        case TheDayBefore:
        {
            [_theDayBeforeLabel setText:dateStr];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void) updateDayAndSyncStatusLabels
{
    last3Days = [CBDateUtils lastThreeDays];
    NSInteger dayIndex = TheDayBefore;
    for (NSDate* day in last3Days)
    {        
        [self updateDayLabel:day dayIndex:dayIndex];
        
        BOOL isThidDaySync = [[UserDefaultsModule sharedInstance] isThisDaySync:day];
        if (!isThidDaySync)
        {
            [self updateSyncStatusLabels:dayIndex syncStatus:NSLocalizedString(@"Unsync", nil)];
        }
        else
        {
            id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
            NSInteger seedCountByDate = [seedDAO countSeedsByDate:day];
            
            [self updateSyncStatusLabels:dayIndex syncStatus:[NSString stringWithFormat:@"%d", seedCountByDate]];
        }
        
        dayIndex = dayIndex + 1;
    }
}

- (void) updateSyncStatusLabels:(NSInteger) dayIndex syncStatus:(NSString*) status
{
    NSAssert(Today >= dayIndex || TheDayBefore <= dayIndex, @"Illegal day index");
    NSAssert(nil != status && 0 < status, @"Illegal status");
    
    dispatch_async(dispatch_get_main_queue(), ^()
    {
        switch (dayIndex)
        {
            case Today:
            {
                [_todaySyncStatusLabel setText:status];
                break;
            }
            case Yesterday:
            {
                [_yesterdaySyncStatusLabel setText:status];
                break;
            }
            case TheDayBefore:
            {
                [_theDayBeforeSyncStatusLabel setText:status];
                break;
            }
            default:
            {
                break;
            }
        }
    });
}

- (void) hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // NavigationBar
    if ([segue.identifier isEqualToString:SEGUE_ID_HOME2TRANSMIT])
    {
        backBarItem = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = stopBarItem;
    }
    else
    {
        self.navigationItem.backBarButtonItem = backBarItem;
    }
    
    // Date for SeedListView
    if ([segue.identifier isEqualToString:SEGUE_ID_HOME2SEEDLIST])
    {
        SeedListViewController* seedListViewController = (SeedListViewController*)segue.destinationViewController;

        if (sender == _todayButton)
        {
            seedListViewController.seedsDate = last3Days[Today];
        }
        else if (sender == _yesterdayButton)
        {
            seedListViewController.seedsDate = last3Days[Yesterday];
        }
        else if (sender == _theDayBeforeButton)
        {
            seedListViewController.seedsDate = last3Days[TheDayBefore];
        }
    }
}

#pragma mark - CBLongTaskStatusHUDDelegate

-(void) taskStarted:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    HUD.mode = MBProgressHUDModeText;
    HUD.minSize = HUD_CENTER_SIZE;
    
    [self updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(1)
    
    HUD.mode = MBProgressHUDModeIndeterminate;
}

-(void) taskIsProcessing:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    [self updateHUDTextStatus:majorStatus minorStatus:minorStatus];
    HUD_DISPLAY(1)
}

-(void) taskCanceld:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    HUD.mode = MBProgressHUDModeText;
    HUD.minSize = HUD_CENTER_SIZE;
    [self updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(2)
}

-(void) taskFailed:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    HUD.mode = MBProgressHUDModeText;
    [self updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(2)
}

-(void) taskFinished:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    HUD.mode = MBProgressHUDModeText;
    [self updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(2)
}

-(void) taskDataUpdated:(id) dataLabel data:(id) data
{
    NSAssert(nil != dataLabel, @"Nil data label");
    NSAssert(nil != data, @"Nil data");
    
    NSString* sLabel = (NSString*)dataLabel;
    NSInteger dayIndex = [sLabel integerValue];
    NSString* sData = (NSString*)data;
    
    [self updateSyncStatusLabels:dayIndex syncStatus:sData];
}

#pragma mark - IBActions

- (IBAction)onClickTodayButton:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_ID_HOME2SEEDLIST sender:_todayButton];
}

- (IBAction)onClickYesterdayButton:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_ID_HOME2SEEDLIST sender:_yesterdayButton];
}

- (IBAction)onClickTheDayBeforeButton:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_ID_HOME2SEEDLIST sender:_theDayBeforeButton];
}
@end
