//
//  SeedDetailViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeedPictureCollectionCell.h"
#import "SeedPictureViewController.h"

#import "SDWebImageManager.h"
#import "CircularProgressView.h"

@interface SeedDetailViewController : UICollectionViewController

@property (nonatomic, strong) Seed* seed;

@end
