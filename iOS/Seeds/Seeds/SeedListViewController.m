//
//  SeedListViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedListViewController.h"

@interface SeedListViewController ()
{
    NSArray* seedList;
    NSArray* firstSeedPictureList;
    Seed* selectedSeed;
}
@end

@implementation SeedListViewController

@synthesize seedsDate = _seedsDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (nil == _seedsDate)
    {
        _seedsDate = [NSDate date];
    }
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    seedList = [seedDAO getSeedsByDate:_seedsDate];
    
    NSMutableArray* pictureArray = [NSMutableArray arrayWithCapacity:seedList.count];
    for (Seed* seed in seedList)
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return seedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_ID_SEEDLISTTABLECELL;
    
#if UI_RENDER_SEEDLISTTABLECELL
    //    static BOOL nibsRegistered = NO;
    //    if (!nibsRegistered)
    //    {
    //        UINib *nib = [UINib nibWithNibName:CELL_ID_SEEDLISTTABLECELL bundle:nil];
    //        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    //        nibsRegistered = YES;
    //    }
    //    [self.tableView registerClass:[SeedListTableCell class] forCellReuseIdentifier:CELL_ID_SEEDLISTTABLECELL];
    //    SeedListTableCell *cell = (SeedListTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    SeedListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SeedListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
#else
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
#endif
    
    Seed* seed = [seedList objectAtIndex:indexPath.row];
    SeedPicture* picture = [firstSeedPictureList objectAtIndex:indexPath.row];
    if (nil != picture && !picture.isPlaceHolder)
    {
        NSURL* imageURL = [[NSURL alloc] initWithString:picture.pictureLink];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager
         downloadWithURL:imageURL
         options:0
         progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             // progression tracking code
             DLog(@"Seed(%d)'s thumbnail downloaded %d of %lld", seed.seedId, receivedSize, expectedSize);
             
             float progressVal = (float)receivedSize / (float)expectedSize;
             [cell.circularProgressView updateProgressCircle:progressVal];
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 //#warning Why below line can't be moved?
                 [cell.circularProgressView removeFromSuperview];
                 // do something with image
                 [cell.thumbnailImageView setImage:image];
             }
         }];
    }
    else
    {
        
    }
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    selectedSeed = [seedList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:SEGUE_ID_SEEDLIST2SEEDDETAIL sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_ID_SEEDLIST2SEEDDETAIL])
    {
        if ([segue.destinationViewController isKindOfClass:[SeedDetailViewController class]])
        {
            SeedDetailViewController* seedDetailViewController = segue.destinationViewController;
            [seedDetailViewController setSeed:selectedSeed];
        }
    }
}

@end
