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
}

@end

@implementation SeedDetailViewController

@synthesize seed = _seed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupView];
    
    [super awakeFromNib];
}

- (void) setupView
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    
    [self _arrangeBarButtons];
    
    [super viewWillAppear:animated];    
}

- (void) _arrangeBarButtons
{
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:_seed];
    BOOL isFileExists = [CBFileUtils isFileExists:torrentFileFullPath];
    if (isFileExists)
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

- (void) setSeed:(Seed *)seed
{
    _seed = seed;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger num = 0;
    
    if (nil != _seed && nil != _seed.seedPictures)
    {
        num = _seed.seedPictures.count;
    }
    
    return num;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SeedPicture* picture = [_seed.seedPictures objectAtIndex:indexPath.row];

    SeedPictureCollectionCell* cell = (SeedPictureCollectionCell*)[cv dequeueReusableCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL forIndexPath:indexPath];
//    if (cell == nil)
//    {
//        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:CELL_ID_SEEDPICTURECOLLECTIONCELL owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
    
    NSUInteger pictureIdInSeed = indexPath.row;
    pictureIdInSeed++;
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
            SeedPicture* selctedPicture = [_seed.seedPictures objectAtIndex:selectedIndexPath.row];
            
            SeedPictureViewController* seedPictureViewController = segue.destinationViewController;
            [seedPictureViewController setSeedPicture:selctedPicture];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

-(void) _onClickDeleteBarButton
{
   [self _showHUD:NSLocalizedString(@"Preparing", nil)];
    
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:_seed];
    
    BOOL isFileExist = [CBFileUtils isFileExists:torrentFileFullPath];
    if (isFileExist)
    {
        BOOL deleteSuccess = [CBFileUtils deleteFile:torrentFileFullPath];
        if (deleteSuccess)
        {
            [self _hideHUD:NSLocalizedString(@"Torrent Deleted", nil)];
        }
        else
        {
            [self _hideHUD:NSLocalizedString(@"Delete Failed", nil)];
        }
    }
    
    [self _arrangeBarButtons];
 
    [self _favoriteSeed:NO];
}

-(void) _favoriteSeed:(BOOL) favorite
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        BOOL flag = [seedDAO favoriteSeed:_seed andFlag:favorite];
        if (flag)
        {
            DLog(@"Favorited seed(%d) in database.", _seed.seedId);
        }
        else
        {
            DLog(@"Failed to favorite seed(%d) in database.", _seed.seedId);
        }
    });
}

#pragma TorrentDownloadAgentDelegate
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

@end
