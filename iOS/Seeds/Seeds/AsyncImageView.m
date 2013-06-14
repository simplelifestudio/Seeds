//
//  AsyncImageView.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-10.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "AsyncImageView.h"

#import "SeedPictureAgent.h"
#import "CBFileUtils.h"

@interface AsyncImageView()
{
    ImageDownloadInProgressBlock _inProgressBlock;
    ImageDownloadFinishBlock _completeBlock;
}

@end

@implementation AsyncImageView

@synthesize circularProgressView = _circularProgressView;
@synthesize circularProgressDelegate = _circularProgressDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupView];
    
    [super awakeFromNib];
}

- (void) setupView
{
    CGRect rect = self.frame;
    CGSize size = rect.size;
    NSInteger halfWidth = size.width / 2;
    NSInteger halfHeight = size.height / 2;
    NSInteger radius = (halfWidth < halfHeight) ? halfWidth : halfHeight * 0.8;
    CGFloat x = halfWidth - radius / 2;
    CGFloat y = halfHeight - radius / 2;
    NSInteger lineWidth = radius / 8;
    
    _circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(x, y, radius, radius) backColor:COLOR_CIRCULAR_PROGRESS_BACKGROUND progressColor:COLOR_CIRCULAR_PROGRESS lineWidth:lineWidth];
    
    _circularProgressDelegate = self;
    
    __block AsyncImageView* blockSelf = self;
    _inProgressBlock = ^(NSUInteger receivedSize, long long expectedSize){
        [blockSelf imageIsLoading:receivedSize expectedSize:expectedSize];
    };
    _completeBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
    {
        [blockSelf imageLoaded:image error:error cacheType:cacheType finished:finished];
    };
}

- (void)loadImageFromURL:(NSURL*)url
{
    if (nil != _circularProgressDelegate)
    {
        [_circularProgressDelegate didStartProgressView];
    }
    
    CommunicationModule* commModule = [CommunicationModule sharedInstance];
    SeedPictureAgent* agent = commModule.seedPictureAgent;
    [agent queueURLRequest:url inProgressBlock:_inProgressBlock completeBlock:_completeBlock];
}

- (void)loadImageFromLocal:(UIImage*) image
{
    if (0 < [[self subviews] count])
    {
        //then this must be another image, the old one is still in subviews, so remove it
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
}

-(void) imageIsLoading:(NSInteger) receivedSize expectedSize:(long long) expectedSize
{
//    DLog(@"Seed's picture downloaded %d of %lld", receivedSize, expectedSize);
    
    float progressVal = (float)receivedSize / (float)expectedSize;
    [_circularProgressView updateProgressCircle:progressVal];
    
    if (nil != _circularProgressDelegate)
    {
        [_circularProgressDelegate didUpdateProgressView];
    }
}

- (void)imageLoaded:(UIImage*) image error:(NSError*) error cacheType:(SDImageCacheType) cacheType finished:(BOOL) finished
{
    if (image && finished)
    {
        if (nil != _circularProgressDelegate)
        {
            [_circularProgressDelegate didFisnishProgressView];
        }
        
        [self loadImageFromLocal:image];
    }
    else
    {
        DLog(@"Failed to load image with error: %@", error.description);
        
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:@"noImage_tableCell" ofType:@"png"];
        UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
        
        [self loadImageFromLocal:placeHolderImage];
    }
}

- (UIImage*) image
{
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

#pragma CircularProgressViewDelegate

- (void)registerCircularProgressDelegate
{
    self.circularProgressView.delegate = self;
}

- (void)didStartProgressView
{
    [self addSubview:_circularProgressView];
}

- (void)didUpdateProgressView
{
    
}

- (void)didFisnishProgressView
{
    [_circularProgressView setHidden:YES];
}

@end
