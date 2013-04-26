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
    NSArray* seedPictures;
}

@end

@implementation SeedDetailViewController

@synthesize seed = _seed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (nil != _seed)
    {
        id<SeedPictureDAO> seedPictureDAO = [DAOFactory getSeedPictureDAO];
        seedPictures = [seedPictureDAO getSeedPicturesBySeedId:_seed.seedId];
    }
    
    [super viewWillAppear:animated];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return seedPictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SeedPictureCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CELL_ID_SEEDPICTURECOLLECTIONCELL forIndexPath:indexPath];
    SeedPicture* picture = [seedPictures objectAtIndex:indexPath.row];

    NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(IMAGE_PLACEHOLDER_COLLECTIONCELL, nil) ofType:@"png"];
    UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    [cell.image setImage:placeHolderImage];
    
    NSURL* imageURL = [[NSURL alloc] initWithString:picture.pictureLink];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager
     downloadWithURL:imageURL
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
         DLog(@"SeedPicture(%d)'s thumbnail(%@) downloaded %d of %lld", picture.pictureId, picture.pictureLink, receivedSize, expectedSize);
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             cell.image.image = image;
         }
     }];
    cell.label.text = [NSString stringWithFormat:@"%d", picture.pictureId];    
    
    return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_ID_SEEDDETAIL2SEEDPICTURE])
    {
        if ([[segue destinationViewController] isKindOfClass:[SeedPictureViewController class]])
        {
            NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            SeedPicture* selctedPicture = [seedPictures objectAtIndex:selectedIndexPath.row];
            
            SeedPictureViewController* seedPictureViewController = segue.destinationViewController;
            [seedPictureViewController setSeedPicture:selctedPicture];
        }
    }
}


@end
