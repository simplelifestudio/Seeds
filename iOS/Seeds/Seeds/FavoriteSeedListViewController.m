//
//  FavoriteSeedListViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "FavoriteSeedListViewController.h"

#import "CBFileUtils.h"

#define _HUD_DELAY 1.5

@interface FavoriteSeedListViewController ()
{
    NSArray* favoriteSeedList;
    NSArray* firstSeedPictureList;
    Seed* selectedSeed;
    BOOL _isSelectedAll;
    
    MBProgressHUD* _HUD;    
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
        [self setupView];
    }
    return self;
}

- (void) awakeFromNib
{
    [self setupView];
    
    [super awakeFromNib];
}

- (void) setupView
{
    UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDLISTTABLECELL bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELL_ID_SEEDLISTTABLECELL];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.minSize = HUD_SIZE;
    [self.view addSubview:_HUD];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initUIBarButtons];
    [self _initTableView];
}

- (void) _initUIBarButtons
{
    [self.navigationController setNavigationBarHidden:FALSE];
    _selectAllBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SelectAll", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onSelectAllBarButtonClicked)];
    _editBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onEditBarButtonClicked)];
    _deleteBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteBarButtonClicked)];
    _cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onCancelBarButtonClicked)];
    self.navigationItem.rightBarButtonItems = @[_editBarButton];
}

- (void) _initTableView
{
    self.tableView.allowsMultipleSelectionDuringEditing = TRUE;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,5)];
    _isSelectedAll = FALSE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
 
    [self _refetchFavoriteSeedsFromDatabase];
    
    [super viewWillAppear:animated];
}

- (void) _refetchFavoriteSeedsFromDatabase
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        favoriteSeedList = [seedDAO getFavoriteSeeds];
        
        NSMutableArray* pictureArray = [NSMutableArray arrayWithCapacity:favoriteSeedList.count];
        for (Seed* seed in favoriteSeedList)
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
        firstSeedPictureList = pictureArray;
        
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{

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
    return favoriteSeedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_ID_SEEDLISTTABLECELL;
    
#if UI_RENDER_SEEDLISTTABLECELL
    SeedListTableCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:CELL_ID_SEEDLISTTABLECELL owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
#else
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
#endif
    
    Seed* seed = [favoriteSeedList objectAtIndex:indexPath.row];
    SeedPicture* picture = [firstSeedPictureList objectAtIndex:indexPath.row];
    
#if UI_RENDER_SEEDLISTTABLECELL
    [cell fillSeed:seed];
    [cell fillSeedPicture:picture];
#else
    [cell.textLabel setText:seed.name];
#endif
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT_SEEDLISTTABLECELL;
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
        
        _isSelectedAll = (favoriteSeedList.count == selectedRows.count) ? YES : NO;
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
        
        selectedSeed = [favoriteSeedList objectAtIndex:indexPath.row];
        
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
            [seedDetailViewController setSeed:selectedSeed];
        }
    }
}

-(void) onSelectAllBarButtonClicked
{
    if (_isSelectedAll)
    {
        NSUInteger rowCount = favoriteSeedList.count;
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
        NSUInteger rowCount = favoriteSeedList.count;
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
    if (!self.tableView.editing && (0 < favoriteSeedList.count))
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
            Seed* seed = [favoriteSeedList objectAtIndex:recordIndex];
            [self _favoriteSeed:seed favorite:NO];
            [self _deleteTorrentFile:seed];
        }
        
//        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView setEditing:FALSE animated:TRUE];
        self.navigationItem.rightBarButtonItems = @[_editBarButton];
        _isSelectedAll = NO;
        
        [self _refetchFavoriteSeedsFromDatabase];
        
        [self _showHUD:NSLocalizedString(@"Delete Done", nil)];
    }
}

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

-(void) onCancelBarButtonClicked
{
    if (self.tableView.editing)
    {
        _isSelectedAll = NO;
        [self.tableView setEditing:FALSE animated:TRUE];
        self.navigationItem.rightBarButtonItems = @[_editBarButton];
    }
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

@end
