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
{
    CircularProgressView* circularProgressView;
}

@end

@implementation SeedPictureViewController

@synthesize seedPicture = _seedPicture;

@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scrollView.photoViewDelegate = self;
    
    NSInteger radius = 150;
    CGFloat x = self.view.center.x - radius / 2;
    CGFloat y = self.view.center.y - radius / 2;
    NSInteger lineWidth = 20;
    circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(x, y, radius, radius) backColor:COLOR_CIRCULAR_PROGRESS_BACKGROUND progressColor:COLOR_CIRCULAR_PROGRESS lineWidth:lineWidth];
    [self registerCircularProgressDelegate];
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
    
    NSURL* imageURL = [NSURL URLWithString:_seedPicture.pictureLink];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager
     downloadWithURL:imageURL
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         DLog(@"SeedPicture(%d)'s thumbnail(%@) downloaded %d of %lld", _seedPicture.pictureId, _seedPicture.pictureLink, receivedSize, expectedSize);
         
         float progressVal = (float)receivedSize / (float)expectedSize;
         [circularProgressView updateProgressCircle:progressVal];
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             [circularProgressView removeFromSuperview];
             [_scrollView displayImage:image];
         }
     }];
    
    [super viewWillAppear:animated];
}

- (void)registerCircularProgressDelegate
{
    circularProgressView.delegate = self;
    [self.view addSubview:circularProgressView];
}

- (void)didUpdateProgressView
{

}

- (void)didStartProgressView
{
    
}

- (void)didFisnishProgressView
{
    [circularProgressView removeFromSuperview];
}

- (void)scrollviewSingleTapped:(UITapGestureRecognizer *)recognizer
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
