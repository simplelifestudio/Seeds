//
//  SeedListTableCell.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircularProgressView.h"

@interface SeedListTableCell : UITableViewCell <CircularProgressDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextView *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UILabel *mosaicLabel;

@property (strong, nonatomic) CircularProgressView* circularProgressView;

-(void) fillSeed:(Seed*) seed;
-(void) fillSeedPicture:(SeedPicture*) picture;

@end
