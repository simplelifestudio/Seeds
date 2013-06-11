//
//  SeedPictureCollectionCell.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBAsyncImageView.h"

@interface SeedPictureCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet CBAsyncImageView *asyncImageView;

-(void) fillSeedPicture:(SeedPicture*) picture;

@end