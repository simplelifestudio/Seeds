//
//  ConfigViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "ConfigViewController.h"

#import "TableViewSwitcherCell.h"
#import "TableViewSegmentCell.h"
#import "TableViewLabelCell.h"
#import "TableViewButtonCell.h"

#import "TorrentDownloadAgent.h"

#import "CBFileUtils.h"

#define HEIGHT_CELL_COMPONENT 27

#define CELL_ID_SWITCHER @"TableViewSwitcherCell"
#define NIB_TABLECELL_SWITCHER @"TableViewSwitcherCell"

#define CELL_ID_SEGMENTER @"TableViewSegmentCell"
#define NIB_TABLECELL_SEGMENTER @"TableViewSegmentCell"

#define CELL_ID_LABEL @"TableViewLabelCell"
#define NIB_TABLECELL_LABEL @"TableViewLabelCell"

#define CELL_ID_BUTTON @"TableViewButtonCell"
#define NIB_TABLECELL_BUTTON @"TableViewButtonCell"

#define SECTION_ITEMCOUNT_CONFIG 5

#define SECTION_INDEX_MODE 0
#define SECTION_ITEMCOUNT_MODE 1
#define SECTION_INDEX_MODE_ITEM_INDEX_MODE 0
#define SEGMENT_INDEX_MODE_STANDALONE 0
#define SEGMENT_INDEX_MODE_SERVER 1

#define SECTION_INDEX_IMAGE 1
#define SECTION_ITEMCOUNT_IMAGE 3
#define SECTION_INDEX_IMAGE_ITEM_INDEX_3GDOWNLOAD 0
#define SECTION_INDEX_IMAGE_ITEM_INDEX_WIFICACHE 1
#define SECTION_INDEX_IMAGE_ITEM_INDEX_CLEARCACHE 2

#define SECTION_INDEX_DATA 2
#define SECTION_ITEMCOUNT_DATA 2
#define SECTION_INDEX_DATA_ITEM_INDEX_CLEARFAVORITES 0
#define SECTION_INDEX_DATA_ITEM_INDEX_CLEARDATABASE 1

#define SECTION_INDEX_PASSCODE 3
#define SECTION_ITEMCOUNT_PASSCODE 2
#define SECTION_INDEX_PASSCODE_ITEM_INDEX_SWITCHER 0
#define SECTION_INDEX_PASSCODE_ITEM_INDEX_MODIFY 1

#define SECTION_INDEX_ABOUT 4
#define SECTION_ITEMCOUNT_ABOUT 2
#define SECTION_INDEX_ABOUT_ITEM_INDEX_FEEDBACK 0
#define SECTION_INDEX_ABOUT_ITEM_INDEX_ABOUT 1

typedef enum {DISABLE_PASSCODE, CHANGE_PASSCODE} PasscodeEnterPurpose;

@interface ConfigViewController () <PAPasscodeViewControllerDelegate, WarningDelegate>
{
    UserDefaultsModule* _userDefaults;
    CommunicationModule* _commModule;
    SeedPictureAgent* _pictureAgent;
    GUIModule* _guiModule;
    
    PAPasscodeViewController* _passcodeViewController;
    
    TableViewSwitcherCell* _runningModeCell;
    TableViewSwitcherCell* _3GDownloadImagesCell;
    TableViewButtonCell* _wifiCacheImagesCell;
    TableViewButtonCell* _clearImagesCacheCell;
    
    TableViewButtonCell* _clearFavoritesCell;
    TableViewButtonCell* _clearDatabaseCell;
    
    TableViewSwitcherCell* _managePasscodeCell;
    TableViewButtonCell* _changePasscodeCell;
    
    TableViewButtonCell* _feedbackCell;
    TableViewButtonCell* _aboutCell;

    PasscodeEnterPurpose _passcodeEnterPurpose;
}

@end

@implementation ConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_ITEMCOUNT_CONFIG;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            return SECTION_ITEMCOUNT_MODE;
        }
        case SECTION_INDEX_IMAGE:
        {
            return SECTION_ITEMCOUNT_IMAGE;
        }
        case SECTION_INDEX_DATA:
        {
            return SECTION_ITEMCOUNT_DATA;
        }
        case SECTION_INDEX_PASSCODE:
        {
            return SECTION_ITEMCOUNT_PASSCODE;
        }
        case SECTION_INDEX_ABOUT:
        {
            return SECTION_ITEMCOUNT_ABOUT;
        }
        default:
        {
            break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSInteger section = indexPath.section;
    NSInteger rowInSection = indexPath.row;
    
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_MODE_ITEM_INDEX_MODE:
                {
                    cell = _runningModeCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SECTION_INDEX_IMAGE:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_IMAGE_ITEM_INDEX_3GDOWNLOAD:
                {
                    cell = _3GDownloadImagesCell;
                    break;
                }
                case SECTION_INDEX_IMAGE_ITEM_INDEX_WIFICACHE:
                {
                    cell = _wifiCacheImagesCell;
                    break;
                }
                case SECTION_INDEX_IMAGE_ITEM_INDEX_CLEARCACHE:
                {
                    cell = _clearImagesCacheCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SECTION_INDEX_DATA:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_DATA_ITEM_INDEX_CLEARFAVORITES:
                {
                    cell = _clearFavoritesCell;
                    break;
                }
                case SECTION_INDEX_DATA_ITEM_INDEX_CLEARDATABASE:
                {
                    cell = _clearDatabaseCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SECTION_INDEX_PASSCODE:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_PASSCODE_ITEM_INDEX_SWITCHER:
                {
                    cell = _managePasscodeCell;
                    break;
                }
                case SECTION_INDEX_PASSCODE_ITEM_INDEX_MODIFY:
                {
                    cell = _changePasscodeCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SECTION_INDEX_ABOUT:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_ABOUT_ITEM_INDEX_FEEDBACK:
                {
                    cell = _feedbackCell;
                    break;
                }
                case SECTION_INDEX_ABOUT_ITEM_INDEX_ABOUT:
                {
                    cell = _aboutCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            sectionName = NSLocalizedString(@"Running", nil);
            break;
        }
        case SECTION_INDEX_IMAGE:
        {
            sectionName = NSLocalizedString(@"Images", nil);
            break;
        }
        case SECTION_INDEX_DATA:
        {
            sectionName = NSLocalizedString(@"Data", nil);
            break;
        }
        case SECTION_INDEX_PASSCODE:
        {
            sectionName = NSLocalizedString(@"Passcode", nil);
            break;
        }
        case SECTION_INDEX_ABOUT:
        {
            sectionName = NSLocalizedString(@"About", nil);
            break;
        }
        default:
        {
            sectionName = @"";
            break;
        }
    }
    return sectionName;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Private Methods

-(void) _setupViewController
{
    [self _setupTableView];
    [self _registerGestureRecognizers];
}

-(void) _setupTableView
{
    _passcodeEnterPurpose = DISABLE_PASSCODE;
    
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _pictureAgent = _commModule.seedPictureAgent;
    
    _guiModule = [GUIModule sharedInstance];
    
    [self _initTableCellList];
}

- (void) _registerGestureRecognizers
{
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeRight:(UISwipeGestureRecognizer*) gestureRecognizer
{    
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) _onRunningModeChanged
{
    BOOL isServerMode = [_runningModeCell.switcher isOn];
    if (isServerMode)
    {
        [self _enableServerMode];
    }
    else
    {
        [self _enableStandaloneMode];
    }
}

- (void) _enableStandaloneMode
{
    [_userDefaults enableServerMode:NO];
}

- (void) _enableServerMode
{
    [_userDefaults enableServerMode:YES];
}

- (void) _activateWiFiImageCacheTask
{
    BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
    if (isWiFiEnabled)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(_wifiImageCacheTaskFinished:skippedCount:)
		                                             name:NOTIFICATION_ID_SEEDPICTUREPREFETCH_FINISHED
		                                           object:nil];
        
        [_wifiCacheImagesCell.button setTitle:@"Syncing" forState:UIControlStateNormal];
        
        NSArray* last3Days = [CBDateUtils lastThreeDays];
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        
        NSArray* seeds = [seedDAO getSeedsByDates:last3Days];
        
        [_pictureAgent prefetchSeedImages:seeds];
    }
    else
    {
        [_guiModule showHUD:NSLocalizedString(@"Internet Disconnected", nil) delay:2];
    }
}

- (void) _wifiImageCacheTaskFinished:(NSUInteger) finishedCount skippedCount:(NSUInteger) skippedCount
{
    NSString* majorStatus = NSLocalizedString(@"Images Prefetched", nil);
    NSMutableString* minorStatus = [NSMutableString string];
    [minorStatus appendString:NSLocalizedString(@"Finished:", nil)];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", finishedCount]];
    [minorStatus appendString:@" "];
    [minorStatus appendString:NSLocalizedString(@"Skipped:", nil)];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", skippedCount]];
    
    [_guiModule showHUD:majorStatus minorStatus:minorStatus delay:2];
}

- (void) _on3GDownloadImagesSwitched
{
    UISwitch* switcher = _3GDownloadImagesCell.switcher;
    [self _set3GDownloadImages:switcher.isOn];
}

- (void) _set3GDownloadImages:(BOOL) flag
{
    UserDefaultsModule* defaults = [UserDefaultsModule sharedInstance];
    [defaults enableDownloadImagesThrough3G:flag];
}

- (void) _refreshWiFiCacheImagesCell
{
    NSUInteger cacheImageCount = [_pictureAgent diskCacheImagesCount];
    NSString* cachedImageCountStr = [NSString stringWithFormat:@"%d", cacheImageCount];
    [_wifiCacheImagesCell.button setTitle:cachedImageCountStr forState:UIControlStateNormal];
}

- (void) _refreshRunningModeCell
{
    BOOL isServerMode = [_userDefaults isServerMode];
    [_runningModeCell.switcher setOn:isServerMode];
}

- (void) _clearImageCache
{
    unsigned long long bytesCacheSize = [_pictureAgent diskCacheImagesSize];
    while (0 < bytesCacheSize)
    {
        [_pictureAgent clearCache];
        bytesCacheSize = [_pictureAgent diskCacheImagesSize];
    }
    
    [self _refreshClearImagesCacheCell];
    
    [self _refreshWiFiCacheImagesCell];
    
    [_guiModule showHUD:NSLocalizedString(@"Images Cache Cleared", nil) delay:2];
}

- (void) _refreshClearImagesCacheCell
{
    unsigned long long bytesCacheSize = [_pictureAgent diskCacheImagesSize];
    NSString* cacheSizeStr = [CBMathUtils readableStringFromBytesSize:bytesCacheSize];
    [_clearImagesCacheCell.button setTitle:cacheSizeStr forState:UIControlStateNormal];
}

- (void) _clearFavoritesBothInDatabaseAndDownloadTorrentsFolder
{
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];    
    NSArray* favoriteSeeds = [seedDAO getFavoriteSeeds];
    for (Seed* seed in favoriteSeeds)
    {
        [seedDAO favoriteSeed:seed andFlag:NO];
        NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:seed];
        [CBFileUtils deleteFile:torrentFileFullPath];
    }
    [self _refreshClearFavoritesCell];
}

- (void) _clearFavorites
{
    [self _clearFavoritesBothInDatabaseAndDownloadTorrentsFolder];
    
    [_guiModule showHUD:NSLocalizedString(@"Favorites Cleared", nil) delay:2];
}

- (void) _refreshClearFavoritesCell
{
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    NSInteger favoritesCount = [seedDAO countFavoriteSeeds];
    NSString* favoritesCountStr = [NSString stringWithFormat:@"%d", favoritesCount];
    [_clearFavoritesCell.button setTitle:favoritesCountStr forState:UIControlStateNormal];
}

- (void) _resetDatabase
{
    [self _clearFavoritesBothInDatabaseAndDownloadTorrentsFolder];
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    [seedDAO deleteAllSeeds];
    [self _refershClearDatabaseCell];
    
    [_userDefaults resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];    
    
    [_guiModule showHUD:NSLocalizedString(@"Database Reseted", nil) delay:2];    
}

- (void) _refershClearDatabaseCell
{
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    NSInteger count = [seedDAO countAllSeeds];
    NSString* countStr = [NSString stringWithFormat:@"%d", count];
    [_clearDatabaseCell.button setTitle:countStr forState:UIControlStateNormal];
}

- (void) _refreshManagePasscodeCellStatus
{
    BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
    [_managePasscodeCell.switcher setOn:isPasscodeSet];
}

- (void) _refreshChangePasscodeCell
{
    static UIColor* originColor = nil;
    
    BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
    if (isPasscodeSet)
    {
        [_changePasscodeCell.button setEnabled:YES];
        
        if (nil != originColor)
        {
            [_changePasscodeCell.button setTitleColor:originColor forState:UIControlStateNormal];
        }
    }
    else
    {
        if (nil == originColor)
        {
            originColor =  _changePasscodeCell.button.titleLabel.textColor;
        }
        
        [_changePasscodeCell.button setEnabled:NO];
        [_changePasscodeCell.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void) _refreshFeedbackCell
{
    
}

- (void) _refreshAboutCell
{
    
}

- (void) _managePasscode
{
    BOOL flag = [_managePasscodeCell.switcher isOn];
    
    if (flag)
    {
        _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    }
    else
    {
        NSString* passcode = [_userDefaults passcode];
        _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
        _passcodeViewController.passcode = passcode;
        _passcodeEnterPurpose = DISABLE_PASSCODE;
    }

    _passcodeViewController.delegate = self;
    _passcodeViewController.simple = YES;
    
    [self presentModalViewController:_passcodeViewController animated:NO];
}

- (void) _changePasscode
{
    BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
    if (isPasscodeSet)
    {
        NSString* passcode = [_userDefaults passcode];
        
        _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
        _passcodeViewController.passcode = passcode;
        
        _passcodeEnterPurpose = CHANGE_PASSCODE;
    }
    else
    {
        _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    }

    _passcodeViewController.delegate = self;
    _passcodeViewController.simple = YES;
    
    [self presentModalViewController:_passcodeViewController animated:NO];
}

- (void) _composeFeedback
{
    
}

- (void) _checkAbout
{
    
}

- (void) _initTableCellList
{
    [self _initRunningModeTableCell];
    
    [self _init3GDownloadImagesCell];
    [self _initWiFiCacheImagesCell];
    [self _initClearImagesCacheCell];
    
    [self _initClearFavoritesCell];
    [self _initClearDatabaseCell];
    
    [self _initManagePasscodeCell];
    [self _initChangePasscodeCell];
    
    [self _initFeedbackCell];
    [self _initAboutCell];
}

- (void) _initRunningModeTableCell
{
    if (nil == _runningModeCell)
    {
        _runningModeCell = [CBUIUtils componentFromNib:NIB_TABLECELL_SWITCHER owner:self options:nil];
        
        [_runningModeCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _runningModeCell.switcherLabel.text = NSLocalizedString(@"Server Mode", nil);
        [_runningModeCell.switcher addTarget:self action:@selector(_onRunningModeChanged) forControlEvents:UIControlEventValueChanged];
        
        [self _refreshRunningModeCell];
        
        [_runningModeCell.switcher setEnabled:NO];
    }
}

- (void) _init3GDownloadImagesCell
{
    if (nil == _3GDownloadImagesCell)
    {
        _3GDownloadImagesCell = [CBUIUtils componentFromNib:NIB_TABLECELL_SWITCHER owner:self options:nil];
        
        [_3GDownloadImagesCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _3GDownloadImagesCell.switcherLabel.text = NSLocalizedString(@"Download Images Through 3G/GPRS", nil);
        [_3GDownloadImagesCell.switcher addTarget:self action:@selector(_on3GDownloadImagesSwitched) forControlEvents:UIControlEventValueChanged];
        
        BOOL flag = [_userDefaults isDownloadImagesThrough3GEnabled];
        [_3GDownloadImagesCell.switcher setOn:flag];
    }
}

- (void) _initWiFiCacheImagesCell
{
    if (nil == _wifiCacheImagesCell)
    {
        _wifiCacheImagesCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_wifiCacheImagesCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _wifiCacheImagesCell.label.text = NSLocalizedString(@"Cache Images Through WiFi", nil);
        
        [self _refreshWiFiCacheImagesCell];
        
        [_wifiCacheImagesCell.button addTarget:self action:@selector(_activateWiFiImageCacheTask) forControlEvents:UIControlEventTouchUpInside];
        [_wifiCacheImagesCell.button setEnabled:NO];
        [_wifiCacheImagesCell.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void) _initClearImagesCacheCell
{
    if (nil == _clearImagesCacheCell)
    {
        _clearImagesCacheCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_clearImagesCacheCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _clearImagesCacheCell.label.text = NSLocalizedString(@"Clear Images Cache", nil);
        
        [self _refreshClearImagesCacheCell];
        
        [_clearImagesCacheCell.button addTarget:self action:@selector(_clearImageCache) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) _initClearFavoritesCell
{
    if (nil == _clearFavoritesCell)
    {
        _clearFavoritesCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_clearFavoritesCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _clearFavoritesCell.label.text = NSLocalizedString(@"Clear Favorites", nil);
        
        [self _refreshClearFavoritesCell];
        
        [_clearFavoritesCell.button addTarget:self action:@selector(_clearFavorites) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) _initClearDatabaseCell
{
    if (nil == _clearDatabaseCell)
    {
        _clearDatabaseCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_clearDatabaseCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _clearDatabaseCell.label.text = NSLocalizedString(@"Reset Database", nil);
        
        [self _refershClearDatabaseCell];
        
        [_clearDatabaseCell.button addTarget:self action:@selector(_resetDatabase) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) _initManagePasscodeCell
{
    if (nil == _managePasscodeCell)
    {
        _managePasscodeCell = [CBUIUtils componentFromNib:NIB_TABLECELL_SWITCHER owner:self options:nil];
        
        [_managePasscodeCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _managePasscodeCell.switcherLabel.text = NSLocalizedString(@"Open Passcode", nil);
        
        [self _refreshManagePasscodeCellStatus];
        
        [_managePasscodeCell.switcher addTarget:self action:@selector(_managePasscode) forControlEvents:UIControlEventValueChanged];
    }
}

- (void) _initChangePasscodeCell
{
    if (nil == _changePasscodeCell)
    {
        _changePasscodeCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_changePasscodeCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _changePasscodeCell.label.text = NSLocalizedString(@"Change Passcode", nil);
        [_changePasscodeCell.button setTitle:NSLocalizedString(@"Change", nil) forState:UIControlStateNormal];
        
        [self _refreshChangePasscodeCell];
        
        [_changePasscodeCell.button addTarget:self action:@selector(_changePasscode) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) _initFeedbackCell
{
    if (nil == _feedbackCell)
    {
        _feedbackCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_feedbackCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _feedbackCell.label.text = NSLocalizedString(@"Feedback", nil);
        [_feedbackCell.button setTitle:NSLocalizedString(@"Compose", nil) forState:UIControlStateNormal];
        
        [self _refreshFeedbackCell];
        
        [_feedbackCell.button addTarget:self action:@selector(_composeFeedback) forControlEvents:UIControlEventTouchUpInside];
        
        [_feedbackCell.button setEnabled:NO];
        [_feedbackCell.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void) _initAboutCell
{
    if (nil == _aboutCell)
    {
        _aboutCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_aboutCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _aboutCell.label.text = NSLocalizedString(@"About", nil);
        [_aboutCell.button setTitle:@"0.1" forState:UIControlStateNormal];
        
        [self _refreshAboutCell];
        
        [_aboutCell.button addTarget:self action:@selector(_checkAbout) forControlEvents:UIControlEventTouchUpInside];
        
        [_aboutCell.button setEnabled:NO];
        [_aboutCell.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
    NSString* passcode = _passcodeViewController.passcode;
    [_userDefaults setPasscode:passcode];
    
    [_passcodeViewController dismissModalViewControllerAnimated:NO];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    [_passcodeViewController dismissModalViewControllerAnimated:NO];
    
    switch (_passcodeEnterPurpose)
    {
        case DISABLE_PASSCODE:
        {
            [_userDefaults enablePasscodeSet:NO];
            [self _refreshChangePasscodeCell];
            
            break;
        }
        case CHANGE_PASSCODE:
        {
            _passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
            _passcodeViewController.delegate = self;
            _passcodeViewController.simple = YES;
            
            [self presentModalViewController:_passcodeViewController animated:NO];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    NSString* passcode = _passcodeViewController.passcode;
    [_userDefaults setPasscode:passcode];
    
    [self _refreshChangePasscodeCell];
    
    [_passcodeViewController dismissModalViewControllerAnimated:NO];
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

@end
