//
//  SeedDetailViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDetailViewController.h"

#import "CBFileUtils.h"
#import "CBNotificationListenable.h"

#import "SeedsDownloadAgent.h"
#import "TorrentDownloadAgent.h"

#define _HUD_DISPLAY 1

@interface SeedDetailViewController () <CBNotificationListenable>
{
    UserDefaultsModule* _userDefaults;
    
    CommunicationModule* _commModule;
    SeedsDownloadAgent* _downloadAgent;
    SeedPictureAgent* _pictureAgent;
    ServerAgent* _serverAgent;
    
    GUIModule* _guiModule;
    
    UIBarButtonItem* _favoriteBarButton;
    UIBarButtonItem* _downloadBarButton;
    UIBarButtonItem* _subscribeBarButton;
    UIActivityIndicatorView* _indicatorView;
    
    SeedDetailHeaderView* _headerView;
    
    NSMutableArray* _pagePictureList;
    PagingToolbar* _pagingToolbar;
    
    NSUInteger _currentPage;
    
    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isHeaderViewRefreshing;
}

@end

@implementation SeedDetailViewController

@synthesize seed = _seed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self _setupViewController];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupViewController];
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController.view addSubview:_pagingToolbar];
    
    [self _arrangeBarButtons];
    
    [self _refetchPicturesFromSeed];
    
    [self listenNotifications];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pagingToolbar removeFromSuperview];
    
    [self unlistenNotifications];
    
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        [_pictureAgent clearMemory];
    }];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger num = 0;
    
    if (nil != _pagePictureList)
    {
        num = _pagePictureList.count;
    }
    
    return num;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SeedPicture* picture = [_pagePictureList objectAtIndex:indexPath.row];

    SeedPictureCollectionCell* cell = (SeedPictureCollectionCell*)[cv dequeueReusableCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL forIndexPath:indexPath];
#warning Why UICollectionViewCell object can not be initialized with NIB file?
//    if (nil == cell)
//    {
//        cell = [CBUIUtils componentFromNib:CELL_ID_SEEDPICTURECOLLECTIONCELL owner:self options:nil];
//    }
    cell.asyncImageView.imageType = PictureCollectionCellThumbnail;
    
    NSUInteger pictureIdInSeed = [self _getPictureIdInSeed:indexPath];
    [cell fillSeedPicture:picture pictureIdInSeed:pictureIdInSeed];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_ID_SEEDDETAIL2SEEDPICTURE])
    {
        if ([[segue destinationViewController] isKindOfClass:[SeedPictureViewController class]])
        {
            NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            SeedPicture* selctedPicture = [_pagePictureList objectAtIndex:selectedIndexPath.row];
            
            SeedPictureViewController* seedPictureViewController = segue.destinationViewController;
            [seedPictureViewController setSeedPicture:selctedPicture];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{    
    if([kind isEqual:UICollectionElementKindSectionHeader])
    {
        if (nil == _headerView)
        {
            _headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:VIEW_ID_SEEDDETAILHEADERVIEW forIndexPath:indexPath];
        }
        [_headerView fillSeed:_seed];
    }
    
    return _headerView;
}

#pragma mark - PagingDelegate

-(void) gotoPage:(NSUInteger)pageNum
{
    [_pagingToolbar setCurrentPage:pageNum];
    _currentPage = pageNum;
    
    [self _constructTableDataByPage];
    
    [self _scrollToTableViewTop];
}

#pragma mark - Private Methods

-(NSUInteger) _getPictureIdInSeed:(NSIndexPath*) indexPath
{
    NSUInteger pictureIdInSeed = indexPath.row;
    pictureIdInSeed++;
    pictureIdInSeed = (_pagingToolbar.currentPage - 1) * _pagingToolbar.pageSize + pictureIdInSeed;
    
    return pictureIdInSeed;
}

- (void) _arrangeBarButtons
{
    BOOL isFavorite = _seed.favorite;
    if (isFavorite)
    {
        [_favoriteBarButton setTitle:NSLocalizedString(@"Unfavorite", nil)];
    }
    else
    {
        [_favoriteBarButton setTitle:NSLocalizedString(@"Favorite", nil)];
    }
    
    [_headerView updateFavoriteStatus:isFavorite];
    
    SeedDownloadStatus downloadStatus = [_downloadAgent checkDownloadStatus:_seed];
    [self _refreshUIWithSeedDownloadStatusUpdated:downloadStatus];
    
    BOOL isServerMode = [_userDefaults isServerMode];
    
    if (isServerMode)
    {
        self.navigationItem.rightBarButtonItems = @[_downloadBarButton, _subscribeBarButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[_downloadBarButton];
    }
}

- (void) _refreshUIWithSeedDownloadStatusUpdated:(SeedDownloadStatus) status
{
    [self _refreshDownloadBarButtonWithStatusUpdated:status];
    
    [_headerView updateDownloadStatus:status];
}

- (void) _refreshDownloadBarButtonWithStatusUpdated:(SeedDownloadStatus) status
{
    switch (status)
    {
        case SeedNotDownload:
        {
            [_downloadBarButton setTitle:NSLocalizedString(@"Download", nil)];
            [_downloadBarButton setEnabled:YES];
            break;
        }
        case SeedWaitForDownload:
        {
            [_downloadBarButton setEnabled:NO];
            break;
        }
        case SeedIsDownloading:
        {
            [_downloadBarButton setEnabled:NO];
            break;
        }
        case SeedDownloaded:
        {
            [_downloadBarButton setTitle:NSLocalizedString(@"Delete", nil)];
            [_downloadBarButton setEnabled:YES];
            break;
        }
        case SeedDownloadFailed:
        {
            [_downloadBarButton setTitle:NSLocalizedString(@"Download", nil)];
            [_downloadBarButton setEnabled:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) _constructTableDataByPage
{
    NSUInteger _pageSize = _pagingToolbar.pageSize;
    if (_pageSize >= _seed.seedPictures.count)
    {
        [_pagePictureList removeAllObjects];
        [_pagePictureList addObjectsFromArray:_seed.seedPictures];
    }
    else
    {
        [_pagePictureList removeAllObjects];
        
        if (_pagingToolbar.currentPage != _currentPage)
        {
            _pagingToolbar.currentPage = _currentPage;
        }
        
        NSUInteger pageStartIndex = [_pagingToolbar pageStartItemIndex];
        NSUInteger pageEndIndex = [_pagingToolbar pageEndItemIndex];
        
        for (NSUInteger i = pageStartIndex; i < pageEndIndex; i++)
        {
            SeedPicture* picture = [_seed.seedPictures objectAtIndex:i];
            [_pagePictureList addObject:picture];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.collectionView reloadData];
    });
}

- (void) _setupViewController
{
    [self _setupRefreshHeaderView];
    [self _setupCollectionView];
    [self _setupPagingToolbar];
}

-(void) _scrollToTableViewTop
{
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void) _setupPagingToolbar
{
    _pagingToolbar = [CBUIUtils componentFromNib:NIB_ID_PAGINGTOOLBAR owner:self options:nil];
    _pagingToolbar.pagingDelegate = self;
    _pagingToolbar.pageSize = PAGE_SIZE_SEEDDETAILCOLLECTION;
    
    CGRect toolbarFrame = _pagingToolbar.frame;
    CGRect tableViewFrame = self.view.frame;
    _pagingToolbar.frame = CGRectMake(0, tableViewFrame.size.height - toolbarFrame.size.height + tableViewFrame.origin.y, tableViewFrame.size.width, toolbarFrame.size.height);
    
    [_pagingToolbar setBarStyle:UIBarStyleDefault];
    _pagingToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    _currentPage = 1;
}

- (void) _setupRefreshHeaderView
{
    _isHeaderViewRefreshing = NO;
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat yOffset = self.collectionView.bounds.size.height;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.collectionView.bounds.size.height;
    CGRect frame = CGRectMake(x, y - yOffset, width, height);
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:frame];
    _refreshHeaderView.delegate = self;
    [self.collectionView addSubview:_refreshHeaderView];
    
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void) _setupCollectionView
{
    //    [self.collectionView registerClass:[SeedPictureCollectionCell class] forCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL];
    
    //    UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDPICTURECOLLECTIONCELL bundle:nil];
    //    [self.collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL];
    
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _downloadAgent = _commModule.seedsDownloadAgent;
    _pictureAgent = _commModule.seedPictureAgent;
    _serverAgent = _commModule.serverAgent;
    
    _guiModule = [GUIModule sharedInstance];
    
    [self _setupBarButtonItems];
    
    _headerView = [CBUIUtils componentFromNib:VIEW_ID_SEEDDETAILHEADERVIEW owner:self options:nil];
    
    _pagePictureList = [NSMutableArray array];
    
    [self _registerGestureRecognizers];
}

- (void) _setupBarButtonItems
{
    UINib* headerViewNib = [UINib nibWithNibName:VIEW_ID_SEEDDETAILHEADERVIEW bundle:nil];
    [self.collectionView registerNib:headerViewNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VIEW_ID_SEEDDETAILHEADERVIEW];

    _favoriteBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorite", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(_onClickFavoriteBarButton)];
    
    _downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Download", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(_onClickDownloadBarButton)];
    
    _subscribeBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Subscribe", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(_onClickSubscribeBarButton)];
    
    CGRect frame = CGRectMake(0, 0, 48, 20);
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.frame = frame;
    [_indicatorView startAnimating];
    _indicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.rightBarButtonItems = @[_downloadBarButton, _subscribeBarButton];
}

- (void) _registerGestureRecognizers
{
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeLeft:)];
    [swipeLeftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.collectionView addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.collectionView addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSUInteger x = _pagingToolbar.currentPage;
    x++;
    x = (x <= _pagingToolbar.pageCount) ? x : 1;
    
    if (x != _pagingToolbar.currentPage)
    {
        [self gotoPage:x];
    }
}

- (void) _handleSwipeRight:(UISwipeGestureRecognizer*) gestureRecognizer
{
    NSUInteger x = _pagingToolbar.currentPage;
    x--;
    
    if (1 <= x)
    {
        [self gotoPage:x];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

-(void) _onClickFavoriteBarButton
{
    NSString* title = [_favoriteBarButton title];
    if ([title isEqualToString:NSLocalizedString(@"Favorite", nil)])
    {
        [self _favoriteSeed:YES];
    }
    else
    {
        [self _favoriteSeed:NO];
    }
}

- (void) _onClickDownloadBarButton
{
    NSString* title = [_downloadBarButton title];
    if ([title isEqualToString:NSLocalizedString(@"Download", nil)])
    {
        if (![CBNetworkUtils isWiFiEnabled] && ![CBNetworkUtils is3GEnabled])
        {
            [_guiModule showHUD:NSLocalizedString(@"Internet Disconnected", nil) minorStatus:nil delay:_HUD_DISPLAY];
            return;
        }
        
        [_downloadAgent downloadSeed:_seed];
    }
    else
    {
        [_downloadAgent deleteDownloadedSeed:_seed];
        [_guiModule showHUD:NSLocalizedString(@"Torrent Deleted", nil) minorStatus:nil delay:_HUD_DISPLAY];
    }
}

- (void) _onClickSubscribeBarButton
{
    if (![CBNetworkUtils isWiFiEnabled] && ![CBNetworkUtils is3GEnabled])
    {
        [_guiModule showHUD:NSLocalizedString(@"Internet Disconnected", nil) minorStatus:nil delay:_HUD_DISPLAY];
        return;
    }
    
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    [HUD showAnimated:YES whileExecutingBlock:^(){
        @try
        {
            [_subscribeBarButton setEnabled:NO];
            
            HUD.minSize = HUD_CENTER_SIZE;            
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = NSLocalizedString(@"Subscribing", nil);
            
            NSString* cartId = [_userDefaults cartId];
            NSString* seedIdStr = [NSString stringWithFormat:@"%d", _seed.seedId];
            JSONMessage* responseMessage = [_serverAgent seedsToCartRequest:cartId seedIds:@[seedIdStr]];
            if (nil != responseMessage)
            {
                if (![JSONMessage isErrorResponseMessage:responseMessage])
                {
                    if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_SEEDSTOCARTRESPONSE])
                    {
                        NSDictionary* content = responseMessage.body;
                        NSDictionary* body = [content objectForKey:JSONMESSAGE_KEY_BODY];
                        if (nil == cartId | 0 == cartId.length)
                        {
                            NSString* newCartId = [body objectForKey:JSONMESSAGE_KEY_CARTID];
                            [_userDefaults setCartId:newCartId];
                        }
                        
                        __block BOOL isSeedSubscribed = NO;
                        NSArray* successSeedIdList = [body objectForKey:JSONMESSAGE_KEY_SUCCESSSEEDIDLIST];
                        [successSeedIdList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
                        {
                            NSString* tempSeedIdStr = (NSString*)obj;
                            if ([tempSeedIdStr isEqualToString:seedIdStr])
                            {
                                isSeedSubscribed = YES;
                                *stop = YES;
                            }
                        }];
                        
                        if (isSeedSubscribed)
                        {
                            HUD.mode = MBProgressHUDModeText;
                            HUD.labelText = NSLocalizedString(@"Subscribe Successfully", nil);
                        }
                        else
                        {
                            __block BOOL isSeedSubscribedBefore = NO;
                            NSArray* existSeedIdList = [body objectForKey:JSONMESSAGE_KEY_EXISTSEEDIDLIST];
                            [existSeedIdList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
                             {
                                 NSString* tempSeedIdStr = (NSString*)obj;
                                 if ([tempSeedIdStr isEqualToString:seedIdStr])
                                 {
                                     isSeedSubscribedBefore = YES;
                                     *stop = YES;
                                 }
                             }];
                            
                            if (isSeedSubscribedBefore)
                            {
                                HUD.mode = MBProgressHUDModeText;
                                HUD.labelText = NSLocalizedString(@"Subscribed Before", nil);
                            }
                            else
                            {
                                HUD.mode = MBProgressHUDModeText;
                                HUD.labelText = NSLocalizedString(@"Subscribe Failed", nil);
                            }
                        }
                    }
                    else
                    {
                        HUD.mode = MBProgressHUDModeText;
                        HUD.labelText = NSLocalizedString(@"Subscribe Failed", nil);
                    }
                }
                else
                {
                    HUD.mode = MBProgressHUDModeText;
                    HUD.labelText = NSLocalizedString(@"Subscribe Failed", nil);
                }
            }
            else
            {
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Subscribe Failed", nil);
            }
            
        }
        @catch(NSException* exception)
        {
            DLog(@"Caught an exception: %@", exception.debugDescription);
            
            HUD.labelText = NSLocalizedString(@"Exception Caught", nil);
        }
        @finally
        {
            [NSThread sleepForTimeInterval:_HUD_DISPLAY];
        }
    }
    completionBlock:^()
    {
        [_subscribeBarButton setEnabled:YES];
    }];
}

-(void) _favoriteSeed:(BOOL) favorite
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        BOOL flag = [seedDAO favoriteSeed:_seed andFlag:favorite];
        if (flag)
        {
            _seed.favorite = favorite;
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self _arrangeBarButtons];
            });
        }
    });
}

-(void) _refetchPicturesFromSeed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        
        [_pagingToolbar setItemCount:_seed.seedPictures.count];
        
        [self _constructTableDataByPage];
    });
}

- (void) _refreshFailedSeedPictures
{
    _isHeaderViewRefreshing = YES;
    
    NSUInteger row = 0;
    for (SeedPicture* seedPicture in _pagePictureList)
    {
        BOOL isFailedPicture = [_pictureAgent isLoadFailedSeedPicture:seedPicture];
        if (isFailedPicture)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            SeedPictureCollectionCell* cell = (SeedPictureCollectionCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            [_pictureAgent removeFailedSeedPicture:seedPicture];
            
            NSUInteger pictureIdInSeed = [self _getPictureIdInSeed:indexPath];
            [cell fillSeedPicture:seedPicture pictureIdInSeed:pictureIdInSeed];
        }
        row++;
    }
}

- (void) _doneRefreshFailedSeedPictures
{
	_isHeaderViewRefreshing = NO;
	
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
}

#pragma mark - CBNotificationListenable

-(void) listenNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationReceived:) name:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED object:nil];
}

-(void) unlistenNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED object:nil];
}

-(void) onNotificationReceived:(NSNotification*) notification
{
    if ([notification.name isEqualToString:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED])
    {
        if (nil != notification.userInfo)
        {
            Seed* seed = [notification.userInfo valueForKey:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_SEED];
            NSString* statusStr = [notification.userInfo valueForKey:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_STATUS];
            SeedDownloadStatus status = statusStr.intValue;
            
            if (nil != seed && seed.localId == _seed
                .localId)
            {
                [self _refreshUIWithSeedDownloadStatusUpdated:status];
             
                switch (status)
                {
                    case SeedDownloaded:
                    {
                        [_guiModule showHUD:NSLocalizedString(@"Torrent Downloaded", nil) minorStatus:nil delay:_HUD_DISPLAY];
                        break;
                    }
                    case SeedDownloadFailed:
                    {
                        [_guiModule showHUD:NSLocalizedString(@"Download Failed", nil) minorStatus:nil delay:_HUD_DISPLAY];
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
            }
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self _refreshFailedSeedPictures];
	[self performSelector:@selector(_doneRefreshFailedSeedPictures) withObject:nil afterDelay:0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _isHeaderViewRefreshing;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
