//
//  FavoriteSeedListViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "FavoriteSeedListViewController.h"

#import "CBFileUtils.h"

#define _HUD_DELAY 1

@interface FavoriteSeedListViewController ()
{
    NSArray* _seedList;
    NSArray* _firstSeedPictureList;
    
    Seed* _selectedSeed;
    
    BOOL _isSelectedAll;
    MBProgressHUD* _HUD;
    
    NSMutableArray* _pageSeedList;
    NSMutableArray* _pageFirstSeedPictureList;
    PagingToolbar* _pagingToolbar;
    
    NSUInteger _currentPage;    
}

@property UIBarButtonItem* editBarButton;
@property UIBarButtonItem* selectAllBarButton;
@property UIBarButtonItem* deleteBarButton;
@property UIBarButtonItem* cancelBarButton;
@property NSIndexPath* selectedIndexPathInTableReadingMode;

@end

@implementation FavoriteSeedListViewController

@synthesize editBarButton = _editBarButton;
@synthesize selectAllBarButton = _selectAllBarButton;
@synthesize deleteBarButton = _deleteBarButton;
@synthesize cancelBarButton = _cancelBarButton;
@synthesize selectedIndexPathInTableReadingMode = _selectedIndexPathInTableReadingMode;

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
    
    [self _refetchFavoriteSeedsFromDatabase];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pagingToolbar removeFromSuperview];
    
    [self onCancelBarButtonClicked];
    
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
        
        [self performSegueWithIdentifier:SEGUE_ID_FAVORITESEEDLIST2SEEDDETAIL sender:self];
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
    if ([[segue identifier] isEqualToString:SEGUE_ID_FAVORITESEEDLIST2SEEDDETAIL])
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
            [self _favoriteSeed:seed favorite:NO];
            [self _deleteTorrentFile:seed];
        }
        
        [self onCancelBarButtonClicked];
        
        [self _refetchFavoriteSeedsFromDatabase];
        
//        [self _showHUD:NSLocalizedString(@"Delete Done", nil)];
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

#pragma mark - Private Methods

-(void) _deleteTorrentFile:(Seed*) seed
{
    if (nil == seed)
    {
        return;
    }
    
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:seed];
    [CBFileUtils deleteFile:torrentFileFullPath];
}

-(void) _showHUD:(NSString*) majorStatus
{
    [_HUD show:YES];    
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = majorStatus;
    [_HUD hide:YES afterDelay:_HUD_DELAY];
}

-(void) _favoriteSeed:(Seed*) seed favorite:(BOOL) favorite
{
    if (nil == seed)
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        [seedDAO favoriteSeed:seed andFlag:favorite];
    });
}

- (void) _setupViewController
{
    [self _setupTableView];
    [self _setupPagingToolbar];
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
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.minSize = HUD_SIZE;
    [self.view addSubview:_HUD];
    
    _pageSeedList = [NSMutableArray array];
    _pageFirstSeedPictureList = [NSMutableArray array];
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

- (void) _refetchFavoriteSeedsFromDatabase
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        _seedList = [seedDAO getFavoriteSeeds];
        
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
        
        [self _constructTableDataByPage];
    });
}

@end