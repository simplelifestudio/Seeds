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
    [self setupScrollView];
}

- (void)setupScrollView
{
    _scrollView.delegate = self;    
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bouncesZoom = TRUE;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.scrollsToTop = YES;
    _scrollView.userInteractionEnabled = YES;
    
//    UITapGestureRecognizer *scrollViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//    [scrollViewDoubleTap setNumberOfTapsRequired:2];
//    [_scrollView addGestureRecognizer:scrollViewDoubleTap];
    
    UITapGestureRecognizer *scrollViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewSingleTapped:)];
//    [scrollViewSingleTap requireGestureRecognizerToFail:scrollViewDoubleTap];
    [_scrollView addGestureRecognizer:scrollViewSingleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
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
             
             CGFloat minimumScale;
             
             // imageViewW < selfViewW and imageViewH < selfViewH
             // imageViewW < selfViewW and imageViewH >= selfViewH
             // imageViewW >= selfViewW and imageViewH >= selfViewH
             // imageViewW >= selfViewW and imageViewH < selfViewH

             if (imageViewW < selfViewW)
             {
                 minimumScale = 1.0;
                 CGFloat minimumImageViewH = imageViewH * minimumScale;

                 imageViewX = abs(selfViewW - imageViewW) / 2;

                 if (minimumImageViewH < selfViewH)
                 {
                     imageViewY = abs(selfViewH - minimumImageViewH) / 2;
                 }
             }
             else
             {
                 minimumScale = scrollViewW / imageViewW;

                 CGFloat minimumImageViewH = imageViewH * minimumScale;

                 if (minimumImageViewH < selfViewH)
                 {
                     imageViewY = abs(selfViewH - minimumImageViewH) / 2;
                 }
             }

             _imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
             
             _scrollView.minimumZoomScale = minimumScale;
             _scrollView.zoomScale = minimumScale;

             _scrollView.contentSize = _imageView.frame.size;
             [_scrollView addSubview:_imageView];

//             [_scrollView zoomToRect:CGRectMake(0, 0, imageViewW, imageViewH) animated:NO];             
             
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

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer
{
    CGFloat zs = _scrollView.zoomScale;
    if (_scrollView.zoomScale < _scrollView.maximumZoomScale)
    {
        zs = zs + 1;
    }
    else
    {
        zs = _scrollView.minimumZoomScale;
    }

    [self updateZoomScaleWithGesture:recognizer newScale:zs];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

- (void)scrollviewSingleTapped:(UITapGestureRecognizer *)recognizer
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{

}

- (void)updateZoomScale:(CGFloat)newScale
{
    CGPoint center = CGPointMake(_imageView.bounds.size.width / 2.0, _imageView.bounds.size.height / 2.0);
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScaleWithGesture:(UIGestureRecognizer *)gestureRecognizer newScale:(CGFloat)newScale
{
    CGPoint center = [gestureRecognizer locationInView:gestureRecognizer.view];
    center = [self adjustPointIntoImageView:center];
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center
{
    if (_scrollView.zoomScale != newScale)
    {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:center];
        [_scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    scale = MIN(scale, _scrollView.maximumZoomScale);
    scale = MAX(scale, _scrollView.minimumZoomScale);
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    zoomRect.size.width = _scrollView.frame.size.width / scale;
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);

    return zoomRect;
}

- (CGPoint)adjustPointIntoImageView:(CGPoint)center
{
    BOOL contains = CGRectContainsPoint(_imageView.frame, center);
    
    if (!contains)
    {
        center.x = center.x / _scrollView.zoomScale;
        center.y = center.y / _scrollView.zoomScale;
        
        // adjust center with bounds and scale to be a point within the image view bounds
        CGRect imageViewBounds = _imageView.bounds;
        
        center.x = MAX(center.x, imageViewBounds.origin.x);
        center.x = MIN(center.x, imageViewBounds.origin.x + imageViewBounds.size.height);
        
        center.y = MAX(center.y, imageViewBounds.origin.y);
        center.y = MIN(center.y, imageViewBounds.origin.y + imageViewBounds.size.width);
        
        return center;
    }
    
    return CGPointZero;
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
