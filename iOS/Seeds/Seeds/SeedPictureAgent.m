//
//  SeedPictureAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureAgent.h"

@interface SeedPictureAgent()
{
    SDWebImageManager* _imageManager;
    SDWebImageOptions _downloadOptions;
    SDImageCache* _imageCache;
}

@end

@implementation SeedPictureAgent

SINGLETON(SeedPictureAgent)

+ (UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize
{
    if (nil == image)
    {
        return nil;
    }
    
    CGImageRef imageRef = [image CGImage];
    UIImage *thumb = nil;
    
    float _width = CGImageGetWidth(imageRef);
    float _height = CGImageGetHeight(imageRef);
    
    // hardcode width and height for now, shouldn't stay like that
    float _resizeToWidth;
    float _resizeToHeight;
    
    _resizeToWidth = aSize.width;
    _resizeToHeight = aSize.height;
    
    float _moveX = 0.0f;
    float _moveY = 0.0f;
    
    // determine the start position in the window if it doesn't fit the sizes 100%
    
    // resize the image if it is bigger than the screen only
    if ((_width > _resizeToWidth) || (_height > _resizeToHeight))
    {
        float _amount = 0.0f;
        
        if (_width > _resizeToWidth)
        {
            _amount = _resizeToWidth / _width;
            _width *= _amount;
            _height *= _amount;
        }
        
        if (_height > _resizeToHeight)
        {
            _amount = _resizeToHeight / _height;
            _width *= _amount;
            _height *= _amount;
        }
    }
    
    _width = (NSInteger)_width;
    _height = (NSInteger)_height;
    
    _resizeToWidth = _width;
    _resizeToHeight = _height;
    
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                _resizeToWidth,
                                                _resizeToHeight,
                                                CGImageGetBitsPerComponent(imageRef),
                                                CGImageGetBitsPerPixel(imageRef)*_resizeToWidth,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)
                                                );
    
    // now center the image
    _moveX = (_resizeToWidth - _width) / 2;
    _moveY = (_resizeToHeight - _height) / 2;
    
    CGContextSetRGBFillColor(bitmap, 1.f, 1.f, 1.f, 1.0f);
    CGContextFillRect( bitmap, CGRectMake(0, 0, _resizeToWidth, _resizeToHeight));
    //   CGContextRotateCTM( bitmap, 180*(M_PI/180));
    CGContextDrawImage( bitmap, CGRectMake(_moveX, _moveY, _width, _height), imageRef );
    
    // create a templete imageref.
    CGImageRef ref = CGBitmapContextCreateImage( bitmap );
    thumb = [UIImage imageWithCGImage:ref];
    
    // release the templete imageref.
    CGContextRelease( bitmap );
    CGImageRelease( ref );
    
    return thumb;
}

-(void) instanceInit
{
    _imageManager = [SDWebImageManager new];
    _downloadOptions = SDWebImageLowPriority;
    _imageCache = _imageManager.imageCache;
}

-(void) setMaxConcurrentDownloads:(NSUInteger)number
{
    _imageManager.imageDownloader.maxConcurrentDownloads = number;
}

-(void) setDownloadOptions:(SDWebImageOptions) options
{    
    _downloadOptions = options;
}

-(void) queueRequest:(NSString*) urlPath inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock
{
    if(nil == urlPath)
    {
        DLog(@"Null url path");
        return;
    }
    
    NSURL* url = [NSURL URLWithString:urlPath];
    [_imageManager downloadWithURL:url options:_downloadOptions progress:inProgressBlock completed:completeBlock];    
}

-(void) queueRequest:(NSString *)urlPath completeBlock:(ImageDownloadFinishBlock)completeBlock
{
    [self queueRequest:urlPath inProgressBlock:nil completeBlock:completeBlock];
}

-(void) queueURLRequest:(NSURL*) url inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock
{
    if (nil == url)
    {
        DLog(@"Null url");
        return;
    }
    
    NSString* urlPath = url.absoluteString;
    [self queueRequest:urlPath inProgressBlock:inProgressBlock completeBlock:completeBlock];
}

-(void) queueURLRequest:(NSURL*) url completeBlock:(ImageDownloadFinishBlock)completeBlock
{
    [self queueURLRequest:url inProgressBlock:nil completeBlock:completeBlock];
}

@end
