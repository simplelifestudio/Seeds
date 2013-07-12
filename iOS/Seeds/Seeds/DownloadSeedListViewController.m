//
//  DownloadSeedListViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "DownloadSeedListViewController.h"

#import "CBNotificationListenable.h"
#import "CBFileUtils.h"

#define _HUD_DISPLAY 1

@interface DownloadSeedListViewController () <CBNotificationListenable>
{
    GUIModule* _guiModule;    
    
    CommunicationModule* _commModule;
    SeedsDownloadAgent* _downloadAgent;
    SeedPictureAgent* _pictureAgent;
    
    NSArray* _seedList;
    NSArray* _firstSeedPictureList;
    
    Seed* _selectedSeed;
    
    BOOL _isSelectedAll;
    
    NSMutableArray* _pageSeedList;
    NSMutableArray* _pageFirstSeedPictureList;
    PagingToolbar* _pagingToolbar;
    
    NSUInteger _currentPage;
    
    id<SeedDAO> _seedDAO;
    
    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isHeaderViewRefreshing;
}

@property UIBarButtonItem* editBarButton;
@property UIBarButtonItem* selectAllBarButton;
@property UIBarButtonItem* deleteBarButton;
@property UIBarButtonItem* cancelBarButton;
@property NSIndexPath* selectedIndexPathInTableReadingMode;

@end

@implementation DownloadSeedListViewController

@synthesize editBarButton = _editBarButton;
@synthesize selectAllBarButton = _selectAllBarButton;
@synthesize deleteBarButton = _deleteBarButton;
@synthesize cancelBarButton = _cancelBarButton;
@synthesize selectedIndexPathInTableReadingMode = _selectedIndexPathInTableReadingMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    [self _refetchDownloadSeedsFromAgent];
    
    [self listenNotifications];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pagingToolbar removeFromSuperview];
    
    [self onCancelBarButtonClicked];
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.isEditing)
    {
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        
        if (0 < selectedRows.count)
        {
            self.navigationItem.rightBarButtonItems = @[_deleteBarButton, _selectAllBarButton];
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[_cancelBarButton, _selectAllBarButton];
        }
        
        _isSelectedAll = (_pageSeedList.count == selectedRows.count) ? YES : NO;
    }
    else
    {
        if (nil != _selectedIndexPathInTableReadingMode && _selectedIndexPathInTableReadingMode.row == indexPath.row)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
            _selectedIndexPathInTableReadingMode = nil;
        }
        else
        {
            _selectedIndexPathInTableReadingMode = indexPath;
        }
        
        _selectedSeed = [_pageSeedList objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:SEGUE_ID_DOWNLOADSEEDLIST2SEEDDETAIL sender:self];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        _isSelectedAll = NO;
        
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        if (0 < selectedRows.count)
        {
            self.navigationItem.rightBarButtonItems = @[_deleteBarButton, _selectAllBarButton];
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[_cancelBarButton, _selectAllBarButton];
        }
    }
    else
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_ID_DOWNLOADSEEDLIST2SEEDDETAIL])
    {
        if ([segue.destinationViewController isKindOfClass:[SeedDetailViewController class]])
        {
            SeedDetailViewController* seedDetailViewController = segue.destinationViewController;
            [seedDetailViewController setSeed:_selectedSeed];
        }
    }
}

-(void) onSelectAllBarButtonClicked
{
    if (_isSelectedAll)
    {
        NSUInteger rowCount = _pageSeedList.count;
        for (NSInteger integer = 0; integer < rowCount; integer++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:integer inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
        }
        
        self.navigationItem.rightBarButtonItems = @[_cancelBarButton, _selectAllBarButton];
        _isSelectedAll = NO;
    }
    else
    {
        NSUInteger rowCount = _pageSeedList.count;
        for (NSInteger integer = 0; integer < rowCount; integer++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:integer inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
        }
        
        self.navigationItem.rightBarButtonItems = @[_deleteBarButton, _selectAllBarButton];
        _isSelectedAll = YES;
    }
}

-(void) onEditBarButtonClicked
{
    if (!self.tableView.editing && (0 < _pageSeedList.count))
    {
        self.navigationItem.rightBarButtonItems = @[_cancelBarButton, _selectAllBarButton];
        [self.tableView setEditing:TRUE animated:TRUE];
    }
}

-(void) onDeleteBarButtonClicked
{
    if (self.tableView.editing)
    {
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        for (NSInteger index = 0; index < selectedRows.count ; index++)
        {
            NSIndexPath* indexPath = [selectedRows objectAtIndex:index];
            NSUInteger recordIndex = indexPath.row;
            Seed* seed = [_pageSeedList objectAtIndex:recordIndex];

            [_downloadAgent deleteDownloadedSeed:seed];
        }
        
        [self onCancelBarButtonClicked];
        
        [self _refetchDownloadSeedsFromAgent];

        [_guiModule showHUD:NSLocalizedString(@"Torrent Deleted", nil) minorStatus:nil delay:_HUD_DISPLAY];
    }
}

-(void) onCancelBarButtonClicked
{
    if (self.tableView.editing)
    {
        _isSelectedAll = NO;
        [self.tableView setEditing:FALSE animated:TRUE];
        self.navigationItem.rightBarButtonItems = @[_editBarButton];
    }
}

#pragma mark - PagingDelegate

-(void) gotoPage:(NSUInteger)pageNum
{
    [_pagingToolbar setCurrentPage:pageNum];
    _currentPage = pageNum;
    
    [self _constructTableDataByPage];
    
    [self _scrollToTableViewTop];
}

- (void) _setupViewController
{
    [self _setupTableHeaderView];
    [self _setupTableView];
    [self _setupPagingToolbar];
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
    UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDLISTTABLECELL bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELL_ID_SEEDLISTTABLECELL];
    
    _pageSeedList = [NSMutableArray array];
    _pageFirstSeedPictureList = [NSMutableArray array];
    
    _guiModule = [GUIModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _downloadAgent = _commModule.seedsDownloadAgent;
    _pictureAgent = _commModule.seedPictureAgent;
    
    [self _registerGestureRecognizers];
    
    _seedDAO = [DAOFactory getSeedDAO];
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

- (void) _initUIBarButtons
{
    [self.navigationController setNavigationBarHidden:FALSE];
    _selectAllBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SelectAll", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onSelectAllBarButtonClicked)];
    _editBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onEditBarButtonClicked)];
    _deleteBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteBarButtonClicked)];
    _cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onCancelBarButtonClicked)];
}

- (void) _checkStatusOfEditBarButtonItem
{
    if (0 >= _pageSeedList.count)
    {
        self.navigationItem.rightBarButtonItems = @[];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[_editBarButton];
    }
}

- (void) _initTableView
{
    self.tableView.allowsMultipleSelectionDuringEditing = TRUE;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,5)];
    _isSelectedAll = FALSE;
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
        [self _checkStatusOfEditBarButtonItem];
    });
}

-(void) _scrollToTableViewTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void) _refetchDownloadSeedsFromAgent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){

        _seedList = [_downloadAgent totalSeedList];
        
        NSMutableArray* pictureArray = [NSMutableArray arrayWithCapacity:_seedList.count];
        for (Seed* seed in _seedList)
        {
            BOOL favorite = [_seedDAO isSeedFavoritedWithLocalId:seed.localId];
            seed.favorite = favorite;
            
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
        
        [self _constructTableDataByPage];
    });
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
        SeedListTableCell* cell = (SeedListTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell updateDownloadStatus:status];
    }
}

-(BOOL) _isSeedInPage:(Seed*) seed
{
    BOOL flag = NO;
    
    if (nil != seed)
    {
        for (Seed* s in _pageSeedList)
        {
            if (s.localId == seed.localId)
            {
                flag = YES;
                break;
            }
        }
    }
    
    return flag;
}

-(BOOL) _isSeedInList:(Seed*) seed
{
    BOOL flag = NO;
    
    if (nil != seed)
    {
        for (Seed* s in _seedList)
        {
            if (s.localId == seed.localId)
            {
                flag = YES;
                break;
            }
        }
    }
    
    return flag;
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
            SeedListTableCell* cell = (SeedListTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [_pictureAgent removeFailedSeedPicture:seedPicture];
            [cell fillSeedPicture:seedPicture];
        }
        row++;
    }
}

- (void) _doneRefreshFailedSeedPictures
{
	_isHeaderViewRefreshing = NO;
	
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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
            
            if ([self _isSeedInList:seed] && [self _isSeedInPage:seed])
            {
                NSInteger cellRow = [self _cellRowForSeed:seed];
                [self _updateCellWithSeedDownloadStatus:cellRow status:status];
            }
            else
            {
                [self _refetchDownloadSeedsFromAgent];
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
