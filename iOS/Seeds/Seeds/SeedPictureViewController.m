//
//  SeedPictureViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureViewController.h"

#import "CBUIUtils.h"

@interface SeedPictureViewController () <SeedPictureScrollViewDelegate, CircularProgressDelegate>

@end

@implementation SeedPictureViewController

@synthesize seedPicture = _seedPicture;

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
    _scrollView.photoViewDelegate = self;
}

- (void)pictureViewDidSingleTap:(SeedPictureScrollView *)photoView
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pictureViewDidDoubleTap:(SeedPictureScrollView *)photoView
{

}

- (void)pictureViewDidTwoFingerTap:(SeedPictureScrollView *)photoView
{

}

- (void)pictureViewDidDoubleTwoFingerTap:(SeedPictureScrollView *)photoView
{

}

- (void)logRect:(CGRect)rect withName:(NSString *)name
{
    DLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout
{
    DLog(@"### SeedPictureViewController ###");
    [self logRect:self.view.window.bounds withName:@"self.view.window.bounds"];
    [self logRect:self.view.window.frame withName:@"self.view.window.frame"];
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    [self logRect:applicationFrame withName:@"application frame"];
}

- (void)toggleFullScreen
{
    if (self.navigationController.navigationBar.alpha == 0.0)
    {
        // fade in navigation
        [UIView animateWithDuration:0.4
                animations:^
                {
                    [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationNone];
                    self.navigationController.navigationBar.alpha = 1.0;
                    self.navigationController.toolbar.alpha = 1.0;
                }
                completion:^(BOOL finished)
                {
                }];
    }
    else
    {
        // fade out navigation
        [UIView animateWithDuration:0.4
                animations:^
                {
                    [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationFade];
                    self.navigationController.navigationBar.alpha = 0.0;
                    self.navigationController.toolbar.alpha = 0.0;
                }
                completion:^(BOOL finished)
                {
                }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
//    NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(IMAGE_PLACEHOLDER_PICTUREVIEW, nil) ofType:@"png"];
//    UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
//    [_scrollView displayImage:placeHolderImage];
    
//    UIActivityIndicatorView* indView = [self progressInd];
//    [_scrollView addSubview:indView];

    UIColor *backColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    UIColor *progressColor = [UIColor colorWithRed:82.0/255.0 green:135.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    //alloc CircularProgressView instance
    __block CircularProgressView* circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(41, 57, 238, 238) backColor:backColor progressColor:progressColor lineWidth:30];
    //set CircularProgressView delegate
    circularProgressView.delegate = self;
    //add CircularProgressView
    [self.view addSubview:circularProgressView];

    
    NSURL* imageURL = [NSURL URLWithString:_seedPicture.pictureLink];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager
     downloadWithURL:imageURL
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
         DLog(@"SeedPicture(%d)'s thumbnail(%@) downloaded %d of %lld", _seedPicture.pictureId, _seedPicture.pictureLink, receivedSize, expectedSize);
         
         float progressVal = (float)receivedSize / (float)expectedSize;
         [circularProgressView updateProgressCircle:progressVal];
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             [circularProgressView setHidden:YES];
             [circularProgressView removeFromSuperview];
             [_scrollView displayImage:image];
         }
     }];
    
    [super viewWillAppear:animated];
}

- (void)didUpdateProgressView
{
//    //update timelabel
//    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self formatTime:(int)self.circularProgressView.player.currentTime],[self formatTime:(int)self.circularProgressView.player.duration]];
}

- (void)scrollviewSingleTapped:(UITapGestureRecognizer *)recognizer
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
