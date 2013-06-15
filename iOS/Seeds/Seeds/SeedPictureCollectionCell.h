//
//  SeedPictureCollectionCell.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AsyncImageView.h"

@interface SeedPictureCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;

-(void) fillSeedPicture:(SeedPicture*) picture pictureIdInSeed:(NSUInteger) pictureIdInSeed;

@end