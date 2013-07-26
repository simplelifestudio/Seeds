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
#import "DownloadSeedListViewController.h"

@interface HomeViewController ()
{
    MBProgressHUD* _HUD;
    
    UIBarButtonItem* _backBarItem;
    UIBarButtonItem* _stopBarItem;
    
    NSArray* _last3Days;
    
    UserDefaultsModule* _userDefaults;
    GUIModule* _guiModule;
    
    CommunicationModule* _commModule;
    ServerAgent* _serverAgent;
    SeedPictureAgent* _pictureAgent;
    
    SpiderModule* _spiderModule;
    
    id<SeedDAO> _seedDAO;
}
@end

@implementation HomeViewController

@synthesize todaySyncStatusLabel = _todaySyncStatusLabel;
@synthesize yesterdaySyncStatusLabel = _yesterdaySyncStatusLabel;
@synthesize theDayBeforeSyncStatusLabel = _theDayBeforeSyncStatusLabel;

@synthesize todayButton = _todayButton;
@synthesize yesterdayButton = _yesterdayButton;
@synthesize theDayBeforeButton = _theDayBeforeButton;
@synthesize syncButton = _syncButton;
@synthesize transButton = _transButton;
@synthesize downloadsButton = _downloadsButton;
@synthesize configButton = _configButton;
@synthesize helpButton = _helpButton;
@synthesize statuLabel = _statuLabel;

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
    
    [self _formatButtons];
    
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    SpiderModule* spiderModule = [SpiderModule sharedInstance];
    [spiderModule.spider setSeedsSpiderDelegate:self];

    _commModule = [CommunicationModule sharedInstance];
    _serverAgent = _commModule.serverAgent;
    _serverAgent.delegate = self;
    _pictureAgent = _commModule.seedPictureAgent;
    
    _guiModule = [GUIModule sharedInstance];
    _guiModule.homeViewController = self;
    
    _spiderModule = [SpiderModule sharedInstance];
    
    _seedDAO = [DAOFactory getSeedDAO];
    
    [self _registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        [_pictureAgent clearMemory];
    }];
    
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

    [self setDownloadsButton:nil];
    [self setConfigButton:nil];
    [self setHelpButton:nil];
    [self setStatuLabel:nil];
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
    else if ([segue.identifier isEqualToString:SEGUE_ID_HOME2SEEDLISTSMALLER])
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
    _HUD.minSize = HUD_CENTER_SIZE;
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
    NSInteger seedCountByDate = sData.integerValue;
    NSString* syncStatus = [NSString stringWithFormat:NSLocalizedString(@"Seeds: %d", nil), seedCountByDate];
    
    [self _refreshSyncStatusLabels:dayIndex syncStatus:syncStatus];
}

-(void) showHUD
{
    _HUD.minShowTime = 1.0f;
    _HUD.minSize = HUD_CENTER_SIZE;
    [_HUD show:YES];
}

-(void) hideHUD
{
    [self hideHUD:0];
}

-(void) hideHUD:(NSTimeInterval) delay
{
    [_HUD hide:YES afterDelay:delay];
}

#pragma mark - IBActions

- (IBAction)onClickSyncButton:(id)sender
{
    [self _syncSeedsInfoTask];
}

- (IBAction)onClickDownloadButton:(id)sender
{
    NSString* segueId = nil;
    if (IS_IPHONE5)
    {
        segueId = SEGUE_ID_HOME2DOWNLOADSEEDLIST;
    }
    else
    {
        segueId = SEGUE_ID_HOME2DOWNLOADSEEDLIST_SMALLER;
    }
    
    [self performSegueWithIdentifier:segueId sender:_downloadsButton];
}

- (IBAction)onClickTodayButton:(id)sender
{
    NSString* segueId = nil;
    if (IS_IPHONE5)
    {
        segueId = SEGUE_ID_HOME2SEEDLIST;
    }
    else
    {
        segueId = SEGUE_ID_HOME2SEEDLISTSMALLER;
    }
    
    [self performSegueWithIdentifier:segueId sender:_todayButton];
}

- (IBAction)onClickYesterdayButton:(id)sender
{
    NSString* segueId = nil;
    
    if (IS_IPHONE5)
    {
        segueId = SEGUE_ID_HOME2SEEDLIST;
    }
    else
    {
        segueId = SEGUE_ID_HOME2SEEDLISTSMALLER;
    }
    
    [self performSegueWithIdentifier:segueId sender:_yesterdayButton];
}

- (IBAction)onClickTheDayBeforeButton:(id)sender
{
    NSString* segueId = nil;
    
    if (IS_IPHONE5)
    {
        segueId = SEGUE_ID_HOME2SEEDLIST;
    }
    else
    {
        segueId = SEGUE_ID_HOME2SEEDLISTSMALLER;
    }
    
    [self performSegueWithIdentifier:segueId sender:_theDayBeforeButton];
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
            
            NSString* syncStatus = [NSString stringWithFormat:NSLocalizedString(@"Seeds: %d", nil), seedCountByDate];
            [self _refreshSyncStatusLabels:dayIndex syncStatus:syncStatus];
        }
        
        dayIndex = dayIndex + 1;
    }
    
    BOOL isServerMode = [_userDefaults isServerMode];
    NSString* statusStr = (isServerMode) ? NSLocalizedString(@"Server Mode", nil) : NSLocalizedString(@"Standalone Mode", nil);
    _statuLabel.text = statusStr;
    
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        [_seedDAO deleteAllExceptLastThreeDaySeeds:_last3Days];
    }];
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

-(void) _formatButtons
{
    _todayButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _yesterdayButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _theDayBeforeButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _downloadsButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _transButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _configButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _helpButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
}

- (void)_syncSeedsInfoTask
{
    _HUD = [_guiModule.HUDAgent sharedHUD];
    
    BOOL isServerMode = [_userDefaults isServerMode];
    if (isServerMode)
    {
        [_HUD showWhileExecuting:@selector(_syncSeedsInfoFromServer) onTarget:self withObject:nil animated:YES];
    }
    else
    {
        [_HUD showWhileExecuting:@selector(_syncSeedsInfoLocally) onTarget:self withObject:nil animated:YES];        
    }
}

- (void) _syncSeedsInfoFromServer
{
    [_serverAgent syncSeedsInfo];
}

- (void) _syncSeedsInfoLocally
{
    [_spiderModule.spider pullSeedsInfo:_last3Days];
}

@end
