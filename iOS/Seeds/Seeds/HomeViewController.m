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
    MBProgressHUD* _HUD;
    
    UIBarButtonItem* _backBarItem;
    UIBarButtonItem* _stopBarItem;
    
    NSArray* _last3Days;
    
    UserDefaultsModule* _userDefaults;
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
    
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider setSeedsSpiderDelegate:self];

    CommunicationModule* communicationModule = [CommunicationModule sharedInstance];
    ServerAgent* serverAgent = communicationModule.serverAgent;
    serverAgent.delegate = self;
    
    GUIModule* guiModule = [GUIModule sharedInstance];
    guiModule.homeViewController = self;
    
    [self _registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    [self _refreshDayAndSyncStatusLabels];

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
    [self _unregisterNotifications];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // NavigationBar
    if ([segue.identifier isEqualToString:SEGUE_ID_HOME2TRANSMIT])
    {
        _backBarItem = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = _stopBarItem;
    }
    else
    {
        self.navigationItem.backBarButtonItem = _backBarItem;
    }
    
    // Date for SeedListView
    if ([segue.identifier isEqualToString:SEGUE_ID_HOME2SEEDLIST])
    {
        SeedListViewController* seedListViewController = (SeedListViewController*)segue.destinationViewController;

        if (sender == _todayButton)
        {
            seedListViewController.seedsDate = _last3Days[Today];
        }
        else if (sender == _yesterdayButton)
        {
            seedListViewController.seedsDate = _last3Days[Yesterday];
        }
        else if (sender == _theDayBeforeButton)
        {
            seedListViewController.seedsDate = _last3Days[TheDayBefore];
        }
    }
}

#pragma mark - CBLongTaskStatusHUDDelegate

-(void) taskStarted:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    _HUD.minSize = HUD_CENTER_SIZE;
    
    [self _updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(1)
    
    _HUD.mode = MBProgressHUDModeIndeterminate;
}

-(void) taskIsProcessing:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    [self _updateHUDTextStatus:majorStatus minorStatus:minorStatus];
    HUD_DISPLAY(0.5)
}

-(void) taskCanceld:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    _HUD.minSize = HUD_CENTER_SIZE;
    [self _updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(1)
}

-(void) taskFailed:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    [self _updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(1)
}

-(void) taskFinished:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    [self _updateHUDTextStatus:majorStatus minorStatus:nil];
    
    HUD_DISPLAY(1)
}

-(void) taskDataUpdated:(id) dataLabel data:(id) data
{
    NSAssert(nil != dataLabel, @"Nil data label");
    NSAssert(nil != data, @"Nil data");
    
    NSString* sLabel = (NSString*)dataLabel;
    NSInteger dayIndex = [sLabel integerValue];
    NSString* sData = (NSString*)data;
    
    [self _refreshSyncStatusLabels:dayIndex syncStatus:sData];
}

#pragma mark - IBActions

- (IBAction)onClickSyncButton:(id)sender
{
    UIWindow* keyWindow = [CBUIUtils getKeyWindow];
    _HUD = [[MBProgressHUD alloc] initWithWindow:keyWindow];
	[self.navigationController.view addSubview:_HUD];
	_HUD.delegate = self;
    
	[_HUD showWhileExecuting:@selector(_syncSeedsInfoTask) onTarget:self withObject:nil animated:YES];
}

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

#pragma mark - Private Methods

- (void) _refreshSyncStatusLabels:(NSInteger) dayIndex syncStatus:(NSString*) status
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

- (void) _computeLast3Days
{
    _last3Days = [CBDateUtils lastThreeDays];
    [_userDefaults setLastThreeDays:_last3Days];
}

- (void) _refreshDayAndSyncStatusLabels
{
    [self _computeLast3Days];
                  
    NSInteger dayIndex = TheDayBefore;
    for (NSDate* day in _last3Days)
    {
        [self _updateDayLabel:day dayIndex:dayIndex];
        
        BOOL isThidDaySync = [[UserDefaultsModule sharedInstance] isThisDaySync:day];
        if (!isThidDaySync)
        {
            [self _refreshSyncStatusLabels:dayIndex syncStatus:NSLocalizedString(@"Unsync", nil)];
        }
        else
        {
            id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
            NSInteger seedCountByDate = [seedDAO countSeedsByDate:day];
            
            [self _refreshSyncStatusLabels:dayIndex syncStatus:[NSString stringWithFormat:@"%d", seedCountByDate]];
        }
        
        dayIndex = dayIndex + 1;
    }
}

- (void) _appDidEnterBackground
{
    
}

- (void) _appDidBecomeActive
{
    [self _refreshDayAndSyncStatusLabels];
}

- (void) _registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) _unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) _updateDayLabel:(NSDate*) day dayIndex:(DayIndex) dayIndex;
{
    NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
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

-(void) _updateHUDTextStatus:(NSString*) majorStatus minorStatus:(NSString*)minorStatus
{
    if (nil != majorStatus && 0 < majorStatus.length)
    {
        _HUD.labelText = majorStatus;
    }
    
    _HUD.detailsLabelText = minorStatus;
}

- (void)_syncSeedsInfoTask
{
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider pullSeedsInfo:_last3Days];
    
    //    CommunicationModule* communicationModule = [CommunicationModule sharedInstance];
    //    ServerAgent* serverAgent = communicationModule.serverAgent;
    //    [serverAgent syncSeedsInfo];
}

@end
