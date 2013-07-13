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
    NSURL* _url;
    
    ImageDownloadInProgressBlock _inProgressBlock;
    ImageDownloadFinishBlock _completeBlock;
    
    CommunicationModule* _commModule;
    SeedPictureAgent* _agent;
    
    GUIModule* _guiModule;
    
    UIImageView* _exceptionImageView;
}

@end

@implementation AsyncImageView

@synthesize circularProgressView = _circularProgressView;
@synthesize circularProgressDelegate = _circularProgressDelegate;
@synthesize imageType = _imageType;

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
    _commModule = [CommunicationModule sharedInstance];
    _agent = _commModule.seedPictureAgent;
    
    _guiModule = [GUIModule sharedInstance];
    
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
    __block GUIModule* blockGUIModule = _guiModule;
    _inProgressBlock = ^(NSUInteger receivedSize, long long expectedSize){
        [blockSelf imageIsLoading:receivedSize expectedSize:expectedSize];
    };
    _completeBlock = ^(UIImage *image, SeedImageType imageType, NSError *error, SDImageCacheType cacheType, BOOL finished)
    {
        [blockGUIModule setNetworkActivityIndicatorVisible:NO];
        
        [blockSelf imageLoaded:image error:error cacheType:cacheType finished:finished];
    };
}

- (void)removeOriginalImage
{
    if (nil != _exceptionImageView && nil != _exceptionImageView.superview)
    {
        [_exceptionImageView removeFromSuperview];
    }
}

- (void)loadImageFromURL:(NSURL*)url
{
    _url = url;
    
    if (nil != _circularProgressDelegate)
    {
        [_circularProgressDelegate didStartProgressView];
    }
    
    [self removeOriginalImage];
    
    [_agent queueURLRequest:url imageType:_imageType inProgressBlock:_inProgressBlock completeBlock:_completeBlock];
}

- (void)loadImageFromLocal:(UIImage*) image
{
    [self removeOriginalImage];
    
    if (nil == _exceptionImageView)
    {
        _exceptionImageView = [[UIImageView alloc] initWithImage:image];
        _exceptionImageView.contentMode = UIViewContentModeScaleToFill;
        _exceptionImageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    }
    else
    {
        [_exceptionImageView setImage:image];
    }

    [self addSubview:_exceptionImageView];
    _exceptionImageView.frame = self.bounds;
    
    [_exceptionImageView setNeedsLayout];
    [self setNeedsLayout];
}

-(void) imageIsLoading:(NSInteger) receivedSize expectedSize:(long long) expectedSize
{
    [_guiModule setNetworkActivityIndicatorVisible:YES];
    
    float progressVal = (float)receivedSize / (float)expectedSize;
    [_circularProgressView updateProgressCircle:progressVal totalVal:expectedSize];
    
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
        
        if (_imageType != PictureViewFullImage)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){

                [_agent cacheImages:image url:_url];
                UIImage* thumbnail = [_agent imageFromCache:_url imageType:_imageType];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self loadImageFromLocal:thumbnail];
                });
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self loadImageFromLocal:image];
            });
        }
    }
    else
    {
        DLog(@"Failed to load image with error: %@", error.debugDescription);
        
        UIImage* image = [SeedPictureAgent exceptionImageWithImagelType:_imageType imageExceptionType:ErrorImage];

        dispatch_async(dispatch_get_main_queue(), ^(){
            [self loadImageFromLocal:image];        
        });
    }
}

- (UIImage*) image
{
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

- (void) setImageType:(SeedImageType)imageType
{
    _imageType = imageType;
    
    _circularProgressView.imageType = imageType;
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
