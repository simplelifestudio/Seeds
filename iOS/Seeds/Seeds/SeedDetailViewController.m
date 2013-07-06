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

#define _HUD_DELAY 1.5

@interface SeedDetailViewController () <CBNotificationListenable>
{
    SeedsDownloadAgent* _downloadAgent;
    
    MBProgressHUD* _HUD;
    GUIModule* _guiModule;
    
    UIBarButtonItem* _favoriteBarButton;
    UIBarButtonItem* _downloadBarButton;
    UIActivityIndicatorView* _indicatorView;
    
    SeedDetailHeaderView* _headerView;
    
    NSMutableArray* _pagePictureList;
    PagingToolbar* _pagingToolbar;
    
    NSUInteger _currentPage;
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
    
    NSUInteger pictureIdInSeed = indexPath.row;
    pictureIdInSeed++;
    pictureIdInSeed = (_pagingToolbar.currentPage - 1) * _pagingToolbar.pageSize + pictureIdInSeed;
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
            [_downloadBarButton setCustomView:nil];
            [_downloadBarButton setTitle:NSLocalizedString(@"Download", nil)];
            [_downloadBarButton setEnabled:YES];
            break;
        }
        case SeedWaitForDownload:
        {
            [_downloadBarButton setCustomView:_indicatorView];
            [_downloadBarButton setEnabled:NO];
            break;
        }
        case SeedIsDownloading:
        {
            [_downloadBarButton setCustomView:_indicatorView];
            [_downloadBarButton setEnabled:NO];
            break;
        }
        case SeedDownloaded:
        {
            [_downloadBarButton setCustomView:nil];
            [_downloadBarButton setTitle:NSLocalizedString(@"Delete", nil)];
            [_downloadBarButton setEnabled:YES];
            break;
        }
        case SeedDownloadFailed:
        {
            [_downloadBarButton setCustomView:nil];
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

-(void) _showHUD:(NSString*) majorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = majorStatus;
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:1];
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

-(void) _scrollToTableViewTop
{
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void) _setupViewController
{
    [self _setupCollectionView];
    [self _setupPagingToolbar];
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

- (void) _setupCollectionView
{
    //    [self.collectionView registerClass:[SeedPictureCollectionCell class] forCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL];
    
    //    UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDPICTURECOLLECTIONCELL bundle:nil];
    //    [self.collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL];
    
    CommunicationModule* _commModule = [CommunicationModule sharedInstance];
    _downloadAgent = _commModule.seedsDownloadAgent;
    
    _guiModule = [GUIModule sharedInstance];
    
    [self _setupBarButtonItems];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.minSize = HUD_CENTER_SIZE;
    [self.view addSubview:_HUD];
    
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
    
    CGRect frame = CGRectMake(0, 0, 48, 20);
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.frame = frame;
    [_indicatorView startAnimating];
    _indicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.rightBarButtonItems = @[_downloadBarButton, _favoriteBarButton];
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
            [self _showHUD:NSLocalizedString(@"Internet Disconnected", nil)];
            return;
        }
        
        [_downloadAgent downloadSeed:_seed];
    }
    else
    {
        [_downloadAgent deleteDownloadedSeed:_seed];
        [self _showHUD:NSLocalizedString(@"Torrent Deleted", nil)];
    }
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
                        [self _showHUD:NSLocalizedString(@"Torrent Downloaded", nil)];
                        break;
                    }
                    case SeedDownloadFailed:
                    {
                        [self _showHUD:NSLocalizedString(@"Download Failed", nil)];
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

@end
