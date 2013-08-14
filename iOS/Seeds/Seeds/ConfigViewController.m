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

#import "CartIdViewController.h"
#import "TCViewController.h"

#import "CBFileUtils.h"

#define _HUD_DISPLAY 1

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
#define SECTION_ITEMCOUNT_MODE 2
#define SECTION_INDEX_MODE_ITEM_INDEX_MODE 0
#define SECTION_INDEX_MODE_ITEM_INDEX_CARTID 1

#define SECTION_INDEX_IMAGE 1
#define SECTION_ITEMCOUNT_IMAGE 2
#define SECTION_INDEX_IMAGE_ITEM_INDEX_3GDOWNLOAD 0
//#define SECTION_INDEX_IMAGE_ITEM_INDEX_WIFICACHE 1
#define SECTION_INDEX_IMAGE_ITEM_INDEX_CLEARCACHE 1

#define SECTION_INDEX_DATA 2
#define SECTION_ITEMCOUNT_DATA 2
#define SECTION_INDEX_DATA_ITEM_INDEX_CLEARDOWNLOADS 0
//#define SECTION_INDEX_DATA_ITEM_INDEX_CLEARFAVORITES 1
#define SECTION_INDEX_DATA_ITEM_INDEX_CLEARDATABASE 1

#define SECTION_INDEX_PASSCODE 3
#define SECTION_ITEMCOUNT_PASSCODE 2
#define SECTION_INDEX_PASSCODE_ITEM_INDEX_SWITCHER 0
#define SECTION_INDEX_PASSCODE_ITEM_INDEX_MODIFY 1

#define SECTION_INDEX_ABOUT 4

#if WEBSOCKET_ENABLED

#define SECTION_ITEMCOUNT_ABOUT 2
//#define SECTION_INDEX_ABOUT_ITEM_INDEX_FEEDBACK 0
#define SECTION_INDEX_ABOUT_ITEM_INDEX_VERSION 0
#define SECTION_INDEX_ABOUT_ITEM_INDEX_WEBSOCKET 1

#else

#define SECTION_ITEMCOUNT_ABOUT 1
//#define SECTION_INDEX_ABOUT_ITEM_INDEX_FEEDBACK 0
#define SECTION_INDEX_ABOUT_ITEM_INDEX_VERSION 0

#endif

typedef enum {DISABLE_PASSCODE, CHANGE_PASSCODE} PasscodeEnterPurpose;

@interface ConfigViewController () <PAPasscodeViewControllerDelegate, WarningDelegate>
{
    UserDefaultsModule* _userDefaults;
    CommunicationModule* _commModule;
    SeedPictureAgent* _pictureAgent;
    SeedsDownloadAgent* _downloadAgent;

    GUIModule* _guiModule;
    CBHUDAgent* _HUDAgent;
    
    PAPasscodeViewController* _passcodeViewController;
    CartIdViewController* _cartIdViewController;
    
    TableViewSwitcherCell* _runningModeCell;
    TableViewButtonCell* _cartIdCell;
    TableViewSwitcherCell* _3GDownloadImagesCell;
    TableViewButtonCell* _wifiCacheImagesCell;
    TableViewButtonCell* _clearImagesCacheCell;
    
    TableViewButtonCell* _clearDownloadsCell;
    TableViewButtonCell* _clearFavoritesCell;
    TableViewButtonCell* _clearDatabaseCell;
    
    TableViewSwitcherCell* _managePasscodeCell;
    TableViewButtonCell* _changePasscodeCell;
    
    TableViewButtonCell* _feedbackCell;
    TableViewLabelCell* _aboutCell;
    TableViewButtonCell* _wsCell;

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
                case SECTION_INDEX_MODE_ITEM_INDEX_CARTID:
                {
                    cell = _cartIdCell;
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
//                case SECTION_INDEX_IMAGE_ITEM_INDEX_WIFICACHE:
//                {
//                    cell = _wifiCacheImagesCell;
//                    break;
//                }
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
                case SECTION_INDEX_DATA_ITEM_INDEX_CLEARDOWNLOADS:
                {
                    cell = _clearDownloadsCell;
                    break;
                }
//                case SECTION_INDEX_DATA_ITEM_INDEX_CLEARFAVORITES:
//                {
//                    cell = _clearFavoritesCell;
//                    break;
//                }
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
//                case SECTION_INDEX_ABOUT_ITEM_INDEX_FEEDBACK:
//                {
//                    cell = _feedbackCell;
//                    break;
//                }
                case SECTION_INDEX_ABOUT_ITEM_INDEX_VERSION:
                {
                    cell = _aboutCell;
                    break;
                }
#if WEBSOCKET_ENABLED
                case SECTION_INDEX_ABOUT_ITEM_INDEX_WEBSOCKET:
                {
                    cell = _wsCell;
                }
#endif
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
            sectionName = NSLocalizedString(@"Others", nil);
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
    _downloadAgent = _commModule.seedsDownloadAgent;
    
    _guiModule = [GUIModule sharedInstance];
    _HUDAgent = _guiModule.HUDAgent;
    
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
    
    [self _switchRunningMode];
}

- (void) _enableServerMode
{
    [_userDefaults enableServerMode:YES];
    
    [self _switchRunningMode];
}

- (void) _switchRunningMode
{
    MBProgressHUD* HUD = [_HUDAgent sharedHUD];
    [HUD showAnimated:YES whileExecutingBlock:^(){
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Clearing", nil);
        sleep(_HUD_DISPLAY);
        
        [self _clearFavoritesBusinessOnly];
        [self _clearDownloadsBusinessOnly];
        
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        [seedDAO deleteAllSeeds];
        
        [_userDefaults resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        
        [CBAppUtils asyncProcessInMainThread:^(){
            [self _refershClearDatabaseCell];
            [self _refreshCartIdCell];            
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"Mode Switched", nil);
        }];
        
        sleep(_HUD_DISPLAY);
    }];
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
        
        NSArray* last3Days = [_userDefaults lastThreeDays];
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        
        NSArray* seeds = [seedDAO getSeedsByDates:last3Days];
        
        [_pictureAgent prefetchSeedImages:seeds];
    }
    else
    {
        [_guiModule showHUD:NSLocalizedString(@"Internet Disconnected", nil) delay:_HUD_DISPLAY];
    }
}

- (void) _wifiImageCacheTaskFinished:(NSUInteger) finishedCount skippedCount:(NSUInteger) skippedCount
{
    NSString* majorStatus = NSLocalizedString(@"Images Prefetched", nil);
    NSMutableString* minorStatus = [NSMutableString string];
    [minorStatus appendString:NSLocalizedString(@"Finished:", nil)];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", finishedCount]];
    [minorStatus appendString:NSLocalizedString(@"Counting", nil)];
    [minorStatus appendString:NSLocalizedString(@"Skipped:", nil)];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", skippedCount]];
    
    [_guiModule showHUD:majorStatus minorStatus:minorStatus delay:_HUD_DISPLAY];
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

- (void) _refreshCartIdCell
{
    BOOL isServerMode = [_userDefaults isServerMode];    
    if (isServerMode)
    {
        [_cartIdCell.button setEnabled:YES];
        [_cartIdCell.button setTitleColor:COLOR_TEXT_INFO forState:UIControlStateNormal];
    }
    else
    {
        [_cartIdCell.button setEnabled:NO];
        [_cartIdCell.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void) _refreshWiFiCacheImagesCell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        NSUInteger cacheImageCount = [_pictureAgent diskCacheImagesCount];
        NSString* cachedImageCountStr = [NSString stringWithFormat:@"%d", cacheImageCount];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [_wifiCacheImagesCell.button setTitle:cachedImageCountStr forState:UIControlStateNormal];
        });
    });
}

- (void) _refreshClearDownloadsCell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        
        NSUInteger count = [_downloadAgent downloadedSeedCount];
        NSString* countStr = [NSString stringWithFormat:@"%d", count];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [_clearDownloadsCell.button setTitle:countStr forState:UIControlStateNormal];
        });
    });
}

- (void) _refreshRunningModeCell
{
    BOOL isServerMode = [_userDefaults isServerMode];
    [_runningModeCell.switcher setOn:isServerMode];
}

- (void) _clearImageCache
{
    MBProgressHUD* HUD = [_HUDAgent sharedHUD];
    [HUD showAnimated:YES whileExecutingBlock:^(){
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Clearing", nil);
        sleep(_HUD_DISPLAY);
        
        unsigned long long bytesCacheSize = [_pictureAgent diskCacheImagesSize];
        while (0 < bytesCacheSize)
        {
            [_pictureAgent clearCacheBothInMemoryAndDisk];
            bytesCacheSize = [_pictureAgent diskCacheImagesSize];
        }
        
        [self _refreshClearImagesCacheCell];
        [self _refreshWiFiCacheImagesCell];

        [CBAppUtils asyncProcessInMainThread:^(){
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"Images Cache Cleared", nil);
        }];
        
        sleep(_HUD_DISPLAY);
    }];
}

- (void) _refreshClearImagesCacheCell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        unsigned long long bytesCacheSize = [_pictureAgent diskCacheImagesSize];
        NSString* cacheSizeStr = [CBMathUtils readableStringFromBytesSize:bytesCacheSize];

        dispatch_async(dispatch_get_main_queue(), ^(){
            [_clearImagesCacheCell.button setTitle:cacheSizeStr forState:UIControlStateNormal];        
        });
    });
}

- (void) _clearDownloadsBusinessOnly
{
    [_downloadAgent resetAgent];
    
    [self _refreshClearDownloadsCell];
}

- (void) _clearDownloads
{
    MBProgressHUD* HUD = [_HUDAgent sharedHUD];
    [HUD showAnimated:YES whileExecutingBlock:^(){
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Clearing", nil);
        sleep(_HUD_DISPLAY);
        
        [self _clearDownloadsBusinessOnly];
        
        [CBAppUtils asyncProcessInMainThread:^(){
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"Downloads Cleared", nil);
        }];
        
        sleep(_HUD_DISPLAY);
    }];
}

- (void) _clearFavoritesBusinessOnly
{
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    NSArray* favoriteSeeds = [seedDAO getFavoriteSeeds];
    for (Seed* seed in favoriteSeeds)
    {
        [seedDAO favoriteSeed:seed andFlag:NO];
    }
    [self _refreshClearFavoritesCell];
}

- (void) _clearFavorites
{
    [self _clearFavoritesBusinessOnly];
    
    [_guiModule showHUD:NSLocalizedString(@"Favorites Cleared", nil) delay:_HUD_DISPLAY];
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
    MBProgressHUD* HUD = [_HUDAgent sharedHUD];
    [HUD showAnimated:YES whileExecutingBlock:^(){
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Clearing", nil);
        sleep(_HUD_DISPLAY);
        
        [self _clearFavoritesBusinessOnly];
        [self _clearDownloadsBusinessOnly];
        
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        [seedDAO deleteAllSeeds];
        
        [_userDefaults resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY];
        
        [CBAppUtils asyncProcessInMainThread:^(){
            [self _refershClearDatabaseCell];
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"Database Reseted", nil);
        }];
        
        sleep(_HUD_DISPLAY);
    }];
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
    BOOL isPasscodeSet = [_userDefaults isPasscodeSet];
    if (isPasscodeSet)
    {
        [_changePasscodeCell.button setEnabled:YES];
        [_changePasscodeCell.button setTitleColor:COLOR_TEXT_INFO forState:UIControlStateNormal];
    }
    else
    {        
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

- (void) _refreshWSCell
{
    
}

- (void) _manageCartId
{
    if (nil == _cartIdViewController)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
        _cartIdViewController = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_CARTIDVIEWCONTROLLER];
    }
    
    [self.navigationController pushViewController:_cartIdViewController animated:YES];
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
    
    [self presentViewController:_passcodeViewController animated:NO completion:nil];
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
    
    [self presentViewController:_passcodeViewController animated:NO completion:nil];
}

- (void) _composeFeedback
{
    
}

- (void) _checkAbout
{
    
}

- (void) _onClickWSButton
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IPHONE bundle:nil];
    TCViewController* tcVC = [storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_TCVIEWCONTROLLER];
    [self.navigationController pushViewController:tcVC animated:YES];
}

- (void) _initTableCellList
{
    [self _initRunningModeTableCell];
    [self _initCartIdCell];
    
    [self _init3GDownloadImagesCell];
    [self _initWiFiCacheImagesCell];
    [self _initClearImagesCacheCell];
    
    [self _initClearDownloadsCell];
    [self _initClearFavoritesCell];
    [self _initClearDatabaseCell];
    
    [self _initManagePasscodeCell];
    [self _initChangePasscodeCell];
    
    [self _initFeedbackCell];
    [self _initAboutCell];
    [self _initWSCell];
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
    }
}

- (void) _initCartIdCell
{
    if (nil == _cartIdCell)
    {
        _cartIdCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_cartIdCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _cartIdCell.label.text = NSLocalizedString(@"Subscribe Source", nil);
        [_cartIdCell.button setTitle:NSLocalizedString(@"Manage", nil) forState:UIControlStateNormal];
        
        [self _refreshCartIdCell];
        
        [_cartIdCell.button addTarget:self action:@selector(_manageCartId) forControlEvents:UIControlEventTouchUpInside];
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
        [_clearImagesCacheCell.button setTitle:NSLocalizedString(@"Counting", nil) forState:UIControlStateNormal];
        [self _refreshClearImagesCacheCell];
        
        [_clearImagesCacheCell.button addTarget:self action:@selector(_clearImageCache) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) _initClearDownloadsCell
{
    _clearDownloadsCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
    
    [_clearDownloadsCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    _clearDownloadsCell.label.text = NSLocalizedString(@"Clear Downloads", nil);
    [_clearDownloadsCell.button setTitle:NSLocalizedString(@"Counting", nil) forState:UIControlStateNormal];
    [self _refreshClearDownloadsCell];
    
    [_clearDownloadsCell.button addTarget:self action:@selector(_clearDownloads) forControlEvents:UIControlEventTouchUpInside];
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
        _aboutCell = [CBUIUtils componentFromNib:NIB_TABLECELL_LABEL owner:self options:nil];
        
        [_aboutCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _aboutCell.majorLabel.text = NSLocalizedString(@"Version", nil);
        
        NSString* versionStr = [[[NSBundle mainBundle] infoDictionary] valueForKey:BUNDLE_KEY_SHORTVERSION];
        NSString* buildStr = [[[NSBundle mainBundle] infoDictionary] valueForKey:BUNDLE_KEY_BUNDLEVERSION];
        _aboutCell.minorLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version: %@-%@", nil), versionStr, buildStr];;
        _aboutCell.minorLabel.textColor = COLOR_TEXT_INFO;
        
        [self _refreshAboutCell];
    }
}

- (void) _initWSCell
{
    if (nil == _wsCell)
    {
        _wsCell = [CBUIUtils componentFromNib:NIB_TABLECELL_BUTTON owner:self options:nil];
        
        [_wsCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _wsCell.label.text = NSLocalizedString(@"WebSocket", nil);
        [_wsCell.button setTitle:NSLocalizedString(@"Test", nil) forState:UIControlStateNormal];
        
        [_wsCell.button addTarget:self action:@selector(_onClickWSButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self _refreshWSCell];
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
    
    [_passcodeViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    [_passcodeViewController dismissViewControllerAnimated:NO completion:nil];
    
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
            
            [self presentViewController:_passcodeViewController animated:NO completion:nil];
            
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
    
    [_passcodeViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts
{
    if (PASSCODE_ATTEMPT_TIMES <= attempts)
    {
        WarningViewController* warningVC = [_guiModule getWarningViewController:WARNING_ID_PASSCODEFAILEDATTEMPTS delegate:self];
        
        [self presentViewController:warningVC animated:NO completion:nil];
        
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
