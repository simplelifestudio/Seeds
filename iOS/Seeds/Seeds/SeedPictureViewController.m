//
//  SeedPictureViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureViewController.h"

#import "CBUIUtils.h"
#import "SeedPictureAgent.h"

@interface SeedPictureViewController () <SeedPictureScrollViewDelegate, CircularProgressDelegate>
{
    CircularProgressView* _circularProgressView;
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
        [self setupView];
    }
    return self;
}

- (void) setupView
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scrollView.photoViewDelegate = self;
    
    NSInteger radius = 150;
    CGFloat x = self.view.center.x - radius / 2;
    CGFloat y = self.view.center.y - radius / 2;
    NSInteger lineWidth = 20;
    _circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(x, y, radius, radius) backColor:COLOR_CIRCULAR_PROGRESS_BACKGROUND progressColor:COLOR_CIRCULAR_PROGRESS lineWidth:lineWidth];
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
    
    CommunicationModule* commModule = [CommunicationModule sharedInstance];
    SeedPictureAgent* agent = commModule.seedPictureAgent;
    [agent
        queueURLRequest:imageURL
        inProgressBlock:^(NSUInteger receivedSize, long long expectedSize)
        {
            float progressVal = (float)receivedSize / (float)expectedSize;
            [_circularProgressView updateProgressCircle:progressVal];
        }
        completeBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            if (image && finished)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
                    CommunicationModule* commModule = [CommunicationModule sharedInstance];
                    SeedPictureAgent* agent = commModule.seedPictureAgent;
                    
                    [agent cacheThumbnails:image url:imageURL];
                });
                
                [_circularProgressView removeFromSuperview];
                [_scrollView displayImage:image];
            }
            else
            {
//                DLog(@"Failed to load image with error: %@", error.description);
             
                UIImage* image = [SeedPictureAgent exceptionImageWithThumbnailType:SeedPictureViewThumbnail imageExceptionType:ErrorImage];
                [_circularProgressView removeFromSuperview];
                [_scrollView displayImage:image];
            }
        }
    ];
    
    [super viewWillAppear:animated];
}

- (void)registerCircularProgressDelegate
{
    _circularProgressView.delegate = self;
    [self.view addSubview:_circularProgressView];
}

- (void)didUpdateProgressView
{
    
}

- (void)didStartProgressView
{
    
}

- (void)didFisnishProgressView
{
    [_circularProgressView removeFromSuperview];
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
