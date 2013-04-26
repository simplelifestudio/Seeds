//
//  SeedPictureViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureViewController.h"

@interface SeedPictureViewController ()

@end

@implementation SeedPictureViewController

@synthesize seedPicture = _seedPicture;

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
    NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(IMAGE_PLACEHOLDER_PICTUREVIEW, nil) ofType:@"png"];
    UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    [self.imageView setImage:placeHolderImage];
    
    NSURL* imageURL = [NSURL URLWithString:_seedPicture.pictureLink];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager
     downloadWithURL:imageURL
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
         DLog(@"SeedPicture(%d)'s thumbnail(%@) downloaded %d of %lld", _seedPicture.pictureId, _seedPicture.pictureLink, receivedSize, expectedSize);
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             [self.imageView setImage:image];
         }
     }];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
