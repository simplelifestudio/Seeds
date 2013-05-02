//
//  SeedPictureCollectionCell.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircularProgressView.h"

@interface SeedPictureCollectionCell : UICollectionViewCell <CircularProgressDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) CircularProgressView* circularProgressView;

@end
