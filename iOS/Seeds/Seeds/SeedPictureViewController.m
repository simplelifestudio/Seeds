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

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;

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
    [_imageView setUserInteractionEnabled:YES];
    _scrollView.delegate = self; 
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
             [_imageView setImage:image];
             [_imageView sizeToFit];
             
             CGFloat imageW = image.size.width;
             CGFloat imageH = image.size.height;
             
             CGFloat scrollViewW = _scrollView.frame.size.width;
             CGFloat scrollViewH = _scrollView.frame.size.height;
             CGFloat scrollViewX = _scrollView.frame.origin.x;
             CGFloat scrollViewY = _scrollView.frame.origin.y;
             
             CGFloat selfViewW = self.view.frame.size.width;
             CGFloat selfViewH = self.view.frame.size.height;
             CGFloat selfViewX = self.view.frame.origin.x;
             CGFloat selfViewY = self.view.frame.origin.y;

             CGFloat imageViewW = _imageView.frame.size.width;
             CGFloat imageViewH = _imageView.frame.size.height;
             CGFloat imageViewX = _imageView.frame.origin.x;
             CGFloat imageViewY = _imageView.frame.origin.y;
             
             if(imageW > selfViewW)
             {
                 CGFloat w = selfViewW;
                 CGFloat h = imageH * (selfViewW / imageW);
                 CGFloat x = 0;
                 CGFloat y = (h <= selfViewH) ? (abs(selfViewH - h) / 2) : 0;
                 _imageView.frame = CGRectMake(x, y, w, h);
                 _scrollView.contentSize = CGSizeMake(selfViewW, imageH * (selfViewW / imageW));
             }
             else if(imageH > selfViewH)
             {
                 CGFloat w = imageW * (selfViewH / imageH);
                 CGFloat h = imageH;
                 CGFloat x = (w <= selfViewW) ? (abs(selfViewW - w) / 2) : w;
                 CGFloat y = 0;
                 _imageView.frame = CGRectMake(x, y, w, h);
                 _scrollView.contentSize = CGSizeMake(imageW * (selfViewH / imageH), selfViewH);
             }
             else
             {
                 CGFloat x = imageViewX = abs(scrollViewW - imageW) / 2;
                 CGFloat y = imageViewY = abs(scrollViewH - imageH) / 2;
                 
                 _imageView.frame = CGRectMake(x, y, imageW, imageH);
                 _scrollView.contentSize = image.size;
             }
             
             DLog(@"ViewController's Frame: %f, %f, %f, %f", selfViewX, selfViewY
                  , selfViewW, selfViewH);
             DLog(@"ScrollView's Frame: %f, %f, %f, %f", scrollViewX, scrollViewY
                  , scrollViewW, scrollViewH);
             DLog(@"ImageView Frame: %f, %f, %f, %f", imageViewX, imageViewY
                  , imageViewW, imageViewH);
             DLog(@"Image Size: %f, %f", imageW, imageH);
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
