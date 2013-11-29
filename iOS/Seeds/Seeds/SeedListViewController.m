//
//  SeedListViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedListViewController.h"

#import "FlatUIKit.h"
#import "UIToolbar+FlatUI.h"

#import "SeedListTableCell.h"
#import "SeedListTableSmallerCell.h"

#import "CBNotificationListenable.h"

#import "PagingToolbar.h"

@interface SeedListViewController () <CBNotificationListenable>
{
    GUIModule* _guiModule;
    CBHUDAgent* _HUDAgent;
    
    CommunicationModule* _commModule;
    SeedsDownloadAgent* _downloadAgent;
    SeedPictureAgent* _pictureAgent;
    
    NSArray* _seedList;
    NSArray* _firstSeedPictureList;
    
    Seed* _selectedSeed;
    
    NSMutableArray* _pageSeedList;
    NSMutableArray* _pageFirstSeedPictureList;    
    PagingToolbar* _pagingToolbar;
    
    NSUInteger _currentPage;
    
    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isHeaderViewRefreshing;
}
@end

@implementation SeedListViewController

@synthesize seedsDate = _seedsDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self _setupViewController];
    }
    return self;
}

- (void) awakeFromNib
{
    [self _setupViewController];
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initUIBarButtons];
    [self _initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController.view addSubview:_pagingToolbar];
    
    [self _refetchSeedsByDateFromDatabase];
    
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

#pragma mark - Public Methods

- (void) setSeedsDate:(NSDate *)seedsDate
{
    _seedsDate = seedsDate;
    
    NSString* shortDayStr = [CBDateUtils shortDateString:seedsDate];
    self.title = shortDayStr;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pageSeedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE5)
    {
        SeedListTableCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SEEDLISTTABLECELL forIndexPath:indexPath];
        if (nil == cell)
        {
            cell = [CBUIUtils componentFromNib:CELL_ID_SEEDLISTTABLECELL owner:self options:nil];
        }
        

        
        Seed* seed = [_pageSeedList objectAtIndex:indexPath.row];
        SeedPicture* picture = [_pageFirstSeedPictureList objectAtIndex:indexPath.row];
        
        [cell fillSeed:seed];
        [cell fillSeedPicture:picture];
        
        SeedDownloadStatus status = [_downloadAgent checkDownloadStatus:seed];
        [cell updateDownloadStatus:status];
        [cell updateFavoriteStatus:seed.favorite];
        
        return cell;        
    }
    else
    {
        SeedListTableSmallerCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SEEDLISTTABLESMALLERCELL forIndexPath:indexPath];
        if (nil == cell)
        {
            cell = [CBUIUtils componentFromNib:CELL_ID_SEEDLISTTABLESMALLERCELL owner:self options:nil];
        }
        
        Seed* seed = [_pageSeedList objectAtIndex:indexPath.row];
        SeedPicture* picture = [_pageFirstSeedPictureList objectAtIndex:indexPath.row];
        
        [cell fillSeed:seed];
        [cell fillSeedPicture:picture];
        
        SeedDownloadStatus status = [_downloadAgent checkDownloadStatus:seed];
        [cell updateDownloadStatus:status];
        [cell updateFavoriteStatus:seed.favorite];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    _selectedSeed = [_pageSeedList objectAtIndex:indexPath.row];
    
    NSString* segueId = nil;
    if (IS_IPHONE5)
    {
        segueId = SEGUE_ID_SEEDLIST2SEEDDETAIL;
    }
    else
    {
        segueId = SEGUE_ID_SEEDLISTSMALLER2SEEDDETAILSMALLER;
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_ID_SEEDLIST2SEEDDETAIL])
    {
        if ([segue.destinationViewController isKindOfClass:[SeedDetailViewController class]])
        {
            SeedDetailViewController* seedDetailViewController = segue.destinationViewController;
            [seedDetailViewController setSeed:_selectedSeed];
        }
    }
    else if ([segue.identifier isEqualToString:SEGUE_ID_SEEDLISTSMALLER2SEEDDETAILSMALLER])
    {
        if ([segue.destinationViewController isKindOfClass:[SeedDetailViewController class]])
        {
            SeedDetailViewController* seedDetailViewController = segue.destinationViewController;
            [seedDetailViewController setSeed:_selectedSeed];
        }
    }
}

#pragma mark - PagingDelegate

-(void) gotoPage:(NSUInteger)pageNum
{
    BOOL isTurningRight = (_currentPage < pageNum) ? YES : NO;
    NSString* animationSubType = (isTurningRight) ? kCATransitionFromRight : kCATransitionFromLeft;
    
    [_pagingToolbar setCurrentPage:pageNum];
    _currentPage = pageNum;

    [self _anmicateView:animationSubType];
    
    [self _constructTableDataByPage];
    
    [self _scrollToTableViewTop];
}

#pragma mark - Private Methods

- (void) _setupViewController
{
    [self _setupTableHeaderView];
    [self _setupTableView];
    [self _setupPagingToolbar];
    
    [self _formatFlatUI];
}

- (void) _setupTableHeaderView
{
    _isHeaderViewRefreshing = NO;
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat yOffset = self.tableView.bounds.size.height;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.tableView.bounds.size.height;
    CGRect frame = CGRectMake(x, y - yOffset, width, height);
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:frame];
    _refreshHeaderView.delegate = self;
    [self.tableView addSubview:_refreshHeaderView];
    
	[_refreshHeaderView refreshLastUpdatedDate];    
}

- (void) _setupPagingToolbar
{
    _pagingToolbar = [CBUIUtils componentFromNib:NIB_ID_PAGINGTOOLBAR owner:self options:nil];
    _pagingToolbar.pagingDelegate = self;
    _pagingToolbar.pageSize = PAGE_SIZE_SEEDLISTTABLE;
    
    CGRect toolbarFrame = _pagingToolbar.frame;
    CGRect tableViewFrame = self.view.frame;
    _pagingToolbar.frame = CGRectMake(0, tableViewFrame.size.height - toolbarFrame.size.height + tableViewFrame.origin.y, tableViewFrame.size.width, toolbarFrame.size.height);
    
    [_pagingToolbar setBarStyle:UIBarStyleDefault];
    _pagingToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    _currentPage = 1;
}

- (void) _setupTableView
{
    self.tableView.delegate = self;    
    
    if (IS_IPHONE5)
    {
        UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDLISTTABLECELL bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CELL_ID_SEEDLISTTABLECELL];
    }
    else
    {
        UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDLISTTABLESMALLERCELL bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CELL_ID_SEEDLISTTABLESMALLERCELL];
    }

    _pageSeedList = [NSMutableArray array];
    _pageFirstSeedPictureList = [NSMutableArray array];
    
    _guiModule = [GUIModule sharedInstance];
    _HUDAgent = _guiModule.HUDAgent;
    
    _commModule = [CommunicationModule sharedInstance];
    _downloadAgent = _commModule.serverAgent.downloadAgent;
    _pictureAgent = _commModule.serverAgent.pictureAgent;
    
    [self _registerGestureRecognizers];
}

- (void) _registerGestureRecognizers
{
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeLeft:)];
    [swipeLeftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSUInteger x = _pagingToolbar.currentPage;
    x++;    
//    x = (x <= _pagingToolbar.pageCount) ? x : 1;
//    if (x != _pagingToolbar.currentPage)
    if (x <= _pagingToolbar.pageCount)
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

- (void) _initUIBarButtons
{
    [self.navigationController setNavigationBarHidden:FALSE];
}

- (void) _initTableView
{

}

-(void) _constructTableDataByPage
{
    NSUInteger _pageSize = _pagingToolbar.pageSize;
    if (_pageSize >= _seedList.count)
    {
        [_pageSeedList removeAllObjects];
        [_pageSeedList addObjectsFromArray:_seedList];
        
        [_pageFirstSeedPictureList removeAllObjects];
        [_pageFirstSeedPictureList addObjectsFromArray:_firstSeedPictureList];
    }
    else
    {
        [_pageSeedList removeAllObjects];
        [_pageFirstSeedPictureList removeAllObjects];
        
        if (_pagingToolbar.currentPage != _currentPage)
        {
            _pagingToolbar.currentPage = _currentPage;
        }
        
        NSUInteger pageStartIndex = [_pagingToolbar pageStartItemIndex];
        NSUInteger pageEndIndex = [_pagingToolbar pageEndItemIndex];
        
        for (NSUInteger i = pageStartIndex; i < pageEndIndex; i++)
        {
            Seed* seed = [_seedList objectAtIndex:i];
            [_pageSeedList addObject:seed];
            
            SeedPicture* picture = [_firstSeedPictureList objectAtIndex:i];
            [_pageFirstSeedPictureList addObject:picture];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void) _scrollToTableViewTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(void) _refetchSeedsByDateFromDatabase
{
    if (nil == _seedsDate)
    {
        _seedsDate = [NSDate date];
    }
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    _seedList = [seedDAO getSeedsByDate:_seedsDate];
    
    NSMutableArray* pictureArray = [NSMutableArray arrayWithCapacity:_seedList.count];
    for (Seed* seed in _seedList)
    {
        SeedPicture* picture = nil;
        if (nil != seed.seedPictures && 0 < seed.seedPictures.count)
        {
            picture = seed.seedPictures[0];
        }
        
        if (nil == picture)
        {
            picture = [SeedPicture placeHolder];
        }
        [pictureArray addObject:picture];
    }
    _firstSeedPictureList = pictureArray;
    
    [_pagingToolbar setItemCount:_seedList.count];
    
    [CBAppUtils asyncProcessInMainThread:^(){
        [self _constructTableDataByPage];
    }];
}

-(NSInteger) _cellRowForSeed:(Seed*) seed
{
    NSInteger row = -1;
    
    if (nil != seed)
    {
        for (int i = 0; i < _pageSeedList.count; i++)
        {
            Seed* s = [_pageSeedList objectAtIndex:i];
            if (seed.localId == s.localId)
            {
                row = i;
                break;
            }
        }
    }
    
    return row;
}

- (void) _updateCellWithSeedDownloadStatus:(NSInteger) row status:(SeedDownloadStatus) status
{
    if (0 <= row)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];

        if (IS_IPHONE5)
        {
            SeedListTableCell* cell = (SeedListTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell updateDownloadStatus:status];
        }
        else
        {
            SeedListTableSmallerCell* cell = (SeedListTableSmallerCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell updateDownloadStatus:status];
        }
    }
}

- (void) _refreshFailedSeedPictures
{
    _isHeaderViewRefreshing = YES;
    
    NSUInteger row = 0;
    for (SeedPicture* seedPicture in _pageFirstSeedPictureList)
    {
        BOOL isFailedPicture = [_pictureAgent isLoadFailedSeedPicture:seedPicture];
        if (isFailedPicture)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];

            if (IS_IPHONE5)
            {
                SeedListTableCell* cell = (SeedListTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                [_pictureAgent removeFailedSeedPicture:seedPicture];
                [cell fillSeedPicture:seedPicture];
            }
            else
            {
                SeedListTableSmallerCell* cell = (SeedListTableSmallerCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                [_pictureAgent removeFailedSeedPicture:seedPicture];
                [cell fillSeedPicture:seedPicture];
            }
        }
        row++;
    }
}

- (void) _doneRefreshFailedSeedPictures
{
	_isHeaderViewRefreshing = NO;
	
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void) _anmicateView:(NSString*) animationSubType
{
    CATransition* animation = [CATransition animation];
    [animation setDuration:PAGE_ANIMATION_PERIOD];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:PAGE_TIMINGFUNCTION]];
    [animation setType:PAGE_ANIMATION_TYPE];
    [animation setSubtype: animationSubType];
    [self.tableView.layer addAnimation:animation forKey:PAGE_ANIMATION_KEY];
}

- (void) _formatFlatUI
{
    self.tableView.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    self.tableView.separatorColor = FLATUI_COLOR_TABLE_SEPERATOR;
    
    [_pagingToolbar configureFlatToolbarWithColor:FLATUI_COLOR_TOOLBAR];
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
            
            NSInteger cellRow = [self _cellRowForSeed:seed];
            [self _updateCellWithSeedDownloadStatus:cellRow status:status];
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