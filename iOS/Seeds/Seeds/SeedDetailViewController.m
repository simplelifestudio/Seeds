//
//  SeedDetailViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDetailViewController.h"

@interface SeedDetailViewController ()
{

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
    UINib* nib = [UINib nibWithNibName:CELL_ID_SEEDPICTURECOLLECTIONCELL bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    
    [super viewWillAppear:animated];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    if (cell == nil)
    {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:CELL_ID_SEEDPICTURECOLLECTIONCELL owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell fillSeedPicture:picture];
    
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

@end
