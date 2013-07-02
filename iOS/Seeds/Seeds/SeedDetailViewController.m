//
//  SeedDetailViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDetailViewController.h"

#import "TorrentDownloadAgent.h"
#import "CBFileUtils.h"

#define _HUD_DELAY 1.5

@interface SeedDetailViewController ()
{
    TorrentDownloadAgent* _downloadAgent;
    
    MBProgressHUD* _HUD;
    
    UIBarButtonItem* _deleteBarButton;
    UIBarButtonItem* _downloadBarButton;
    
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
    
    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pagingToolbar removeFromSuperview];
    
    [super viewWillDisappear:animated];
}

- (void) _arrangeBarButtons
{    
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:_seed];
    BOOL isFileExists = [CBFileUtils isFileExists:torrentFileFullPath];
    if (isFileExists && _seed.favorite)
    {
        self.navigationItem.rightBarButtonItems = @[_deleteBarButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[_downloadBarButton];
    }
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

#pragma mark - TorrentDownloadAgentDelegate

-(void) torrentDownloadStarted:(NSString*) torrentCode
{
    _HUD.mode = MBProgressHUDModeIndeterminate;
    _HUD.labelText = NSLocalizedString(@"Torrent Downloading", nil);
}

-(void) torrentDownloadFinished:(NSString*) torrentCode
{
    [self _hideHUD:NSLocalizedString(@"Torrent Downloaded", nil)];

    [self _arrangeBarButtons];
}

-(void) torrentDownloadFailed:(NSString*) torrentCode error:(NSError*) error
{
    [self _hideHUD:NSLocalizedString(@"Download Failed", nil)];
    
    [self _arrangeBarButtons];    
}

-(void) torrentSaveFinished:(NSString*) torrentCode filePath:(NSString*) filePath
{
    [self _hideHUD:NSLocalizedString(@"Torrent Saved", nil)];
    
    [self _arrangeBarButtons];
    
    [self _favoriteSeed:YES];    
}

-(void) torrentSaveFailed:(NSString*) torrentCode filePath:(NSString*) filePath
{
    [self _hideHUD:NSLocalizedString(@"Save Failed", nil)];
    
    [self _arrangeBarButtons];    
}

-(void) _showHUD:(NSString*) majorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = majorStatus;
    [_HUD show:YES];
}

-(void) _hideHUD:(NSString*) majorStatus
{
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = majorStatus;
    [_HUD hide:YES afterDelay:_HUD_DELAY];
}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SeedDetailHeaderView* headerView = nil;
    
    if([kind isEqual:UICollectionElementKindSectionHeader])
    {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:VIEW_ID_SEEDDETAILHEADERVIEW forIndexPath:indexPath];
        [headerView fillSeed:_seed];
    }
    
    return headerView;
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
    
    UINib* headerViewNib = [UINib nibWithNibName:VIEW_ID_SEEDDETAILHEADERVIEW bundle:nil];
    [self.collectionView registerNib:headerViewNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VIEW_ID_SEEDDETAILHEADERVIEW];
    
    _deleteBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_onClickDeleteBarButton)];
    _downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Download", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_onClickDownloadBarButton)];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.minSize = HUD_SIZE;
    [self.view addSubview:_HUD];
    
    _pagePictureList = [NSMutableArray array];
    
    [self _registerGestureRecognizers];
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

-(void) _onClickDeleteBarButton
{
    [self _showHUD:NSLocalizedString(@"Preparing", nil)];
    
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:_seed];
    
    BOOL deleteSuccess = [CBFileUtils deleteFile:torrentFileFullPath];
    if (deleteSuccess)
    {
        [self _hideHUD:NSLocalizedString(@"Torrent Deleted", nil)];
    }
    else
    {
        [self _hideHUD:NSLocalizedString(@"Delete Failed", nil)];
    }
    
    [self _arrangeBarButtons];
    
    [self _favoriteSeed:NO];
}

- (void) _onClickDownloadBarButton
{
    if (![CBNetworkUtils isWiFiEnabled] && ![CBNetworkUtils is3GEnabled])
    {
        [self _showHUD:NSLocalizedString(@"Internet Disconnected", nil)];
        return;
    }
    
    [self _showHUD:NSLocalizedString(@"Preparing", nil)];
    
    TransmissionModule* transModule = [TransmissionModule sharedInstance];
    NSString* downloadDirFullPath = [transModule generateDownloadRootDirectory];
    if (nil == downloadDirFullPath)
    {
        DLog(@"Download root directory is not ready.");
        [self _hideHUD:NSLocalizedString(@"Directory Unready", nil)];
        
        return;
    }
    
    _downloadAgent = [[TorrentDownloadAgent alloc] initWithSeed:_seed downloadPath:downloadDirFullPath];
    [_downloadAgent downloadWithDelegate:self];
}

-(void) _favoriteSeed:(BOOL) favorite
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        [seedDAO favoriteSeed:_seed andFlag:favorite];
    });
}

-(void) _refetchPicturesFromSeed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        
        [_pagingToolbar setItemCount:_seed.seedPictures.count];
        
        [self _constructTableDataByPage];
    });
}

@end
