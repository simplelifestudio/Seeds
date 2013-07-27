//
//  SeedListTableSmallerCell.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AsyncImageView.h"

@interface SeedListTableSmallerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UILabel *mosaicLabel;
@property (weak, nonatomic) IBOutlet UILabel *pictureCountLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;

-(void) fillSeed:(Seed*) seed;
-(void) fillSeedPicture:(SeedPicture*) picture;

-(void) updateDownloadStatus:(SeedDownloadStatus) status;
-(void) updateFavoriteStatus:(BOOL) favorite;

@end
