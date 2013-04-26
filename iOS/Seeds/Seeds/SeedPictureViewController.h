//
//  SeedPictureViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDWebImageManager.h"

@interface SeedPictureViewController : UIViewController

@property (nonatomic, strong) SeedPicture* seedPicture;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
