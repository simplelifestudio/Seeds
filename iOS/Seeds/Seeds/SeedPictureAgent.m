//
//  SeedPictureAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureAgent.h"

#import "SDWebImagePrefetcher.h"

@interface SeedPictureAgent()
{
    SDWebImageManager* _imageManager;
    SDWebImageOptions _downloadOptions;
    SDImageCache* _imageCache;
}

@end

static UIImage *emptyImageInSeedListTableCell, *emptyImageInSeedPictureCollectionCell;
static UIImage *errorImageInSeedListTableCell, *errorImageInSeedPictureCollectionCell, *errorImageInSeedPictureView;

@implementation SeedPictureAgent

SINGLETON(SeedPictureAgent)

+ (void)initialize
{
    if (nil == emptyImageInSeedListTableCell)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:RES_NOIMAGE_TABLECELL ofType:RES_PNG_FILE];
        emptyImageInSeedListTableCell = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    }
    
    if (nil == emptyImageInSeedPictureCollectionCell)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:RES_NOIMAGE_COLLECTIONCELL ofType:RES_PNG_FILE];
        emptyImageInSeedPictureCollectionCell = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    }
    
    if (nil == errorImageInSeedListTableCell)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:RES_XIMAGE_TABLECELL ofType:RES_PNG_FILE];
        errorImageInSeedListTableCell = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    }

    if (nil == errorImageInSeedPictureCollectionCell)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:RES_XIMAGE_COLLECTIONCELL ofType:RES_PNG_FILE];
        errorImageInSeedPictureCollectionCell = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    }

    if (nil == errorImageInSeedPictureView)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:RES_XIMAGE_PICTUREVIEW ofType:RES_PNG_FILE];
        errorImageInSeedPictureView = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
    }
}

+(UIImage*)exceptionImageWithThumbnailType:(ThumbnailType) thumbnailType imageExceptionType:(ImageExceptionType) imageExceptionType;
{
    UIImage* image = nil;
    
    switch (thumbnailType)
    {
        case SeedListTableCellThumbnail:
        {
            switch (imageExceptionType)
            {
                case EmptyImage:
                {
                    image = emptyImageInSeedListTableCell;
                    break;
                }
                case ErrorImage:
                {
                    image = errorImageInSeedListTableCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SeedPictureCollectionCellThumbnail:
        {
            switch (imageExceptionType)
            {
                case EmptyImage:
                {
                    image = emptyImageInSeedPictureCollectionCell;
                    break;
                }
                case ErrorImage:
                {
                    image = errorImageInSeedPictureCollectionCell;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SeedPictureViewThumbnail:
        {
            switch (imageExceptionType)
            {
                case EmptyImage:
                {
                    break;
                }
                case ErrorImage:
                {
                    image = errorImageInSeedPictureView;
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    return image;
}

+ (UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize
{
    if (nil == image)
    {
        return nil;
    }
    
    if (image.size.width <= aSize.width && image.size.height <= aSize.height)
    {
        DLog(@"Image is smaller than thumbnail which is being converted.");
        return image;
    }
    
    CGImageRef imageRef = [image CGImage];
    UIImage *thumb = nil;
    
    float _width = CGImageGetWidth(imageRef);
    float _height = CGImageGetHeight(imageRef);
    
    // hardcode width and height for now, shouldn't stay like that
    float _resizeToWidth = aSize.width;
    float _resizeToHeight = aSize.height;
    
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
    _downloadOptions = SDWebImageLowPriority | SDWebImageRetryFailed;
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

-(void) setMaxCahceAge:(NSUInteger) age
{
    _imageCache.maxCacheAge = age;
}

-(void) queueRequest:(NSString*) urlPath inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock
{
    if(nil == urlPath)
    {
        DLog(@"Null url path");
        return;
    }
    
    BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
    if (isWiFiEnabled)
    {
        NSURL* url = [NSURL URLWithString:urlPath];
        [_imageManager downloadWithURL:url options:_downloadOptions progress:inProgressBlock completed:completeBlock];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
            NSURL* url = [NSURL URLWithString:urlPath];
            NSString* key = [self cacheKeyForURL:url];
            [_imageCache
             queryDiskCacheForKey:key
             done:^(UIImage *image, SDImageCacheType cacheType)
             {
                 BOOL finished = (nil != image) ? YES : NO;
                 completeBlock(image, nil, cacheType, finished);
             }
             ];
        });
    }
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

- (NSString *)cacheKeyForURL:(NSURL *)url
{
    if (_imageManager.cacheKeyFilter)
    {
        return _imageManager.cacheKeyFilter(url);
    }
    else
    {
        return [url absoluteString];
    }
}

-(void) clearCache
{
    [_imageCache cleanDisk];
    
    [_imageCache clearDisk];    
    [_imageCache clearMemory];
}

-(void) cacheThumbnails:(UIImage*) image url:(NSURL*) url
{
    if (nil == image || nil == url)
    {
        DLog(@"Nil image or url");
        return;
    }
    
    NSString* keyInOriginPicture = [self cacheKeyForURL:url];
    
    NSMutableString* keyInSeedListTableCell = [NSMutableString stringWithString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDLISTTABLECELL];
    [keyInSeedListTableCell appendString:keyInOriginPicture];
    
    NSMutableString* keyInSeedPictureCollectionCell = [NSMutableString stringWithString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTURECOLLECTIONCELL];
    [keyInSeedPictureCollectionCell appendString:keyInOriginPicture];
    
    NSMutableString* keyInSeedPictureView = [NSMutableString stringWithString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTUREVIEW];
    [keyInSeedPictureView appendString:keyInOriginPicture];
    
//    @autoreleasepool
//    {
        UIImage* tempCachedImage = [_imageCache imageFromDiskCacheForKey:keyInSeedListTableCell];
        if (!tempCachedImage)
        {
            UIImage* thumbnailInSeedListTableCell = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDLISTTABLECELL];
            [_imageCache storeImage:thumbnailInSeedListTableCell forKey:keyInSeedListTableCell];
        }
        
        tempCachedImage = [_imageCache imageFromDiskCacheForKey:keyInSeedPictureCollectionCell];
        if (!tempCachedImage)
        {
            UIImage* thumbnailInSeedPictureCollectionCell = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDPICTURECOLLECTIONCELL];
            [_imageCache storeImage:thumbnailInSeedPictureCollectionCell forKey:keyInSeedPictureCollectionCell];
        }
        
#if 0
        tempCachedImage = [_imageCache imageFromDiskCacheForKey:keyInSeedPictureView];
        if (!tempCachedImage)
        {
            UIImage* thumbnailInSeedPictureView = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDPICTUREVIEW];
            [_imageCache storeImage:thumbnailInSeedPictureView forKey:keyInSeedPictureView];
        }
#endif
//    }
}

-(UIImage*) thumbnailFromCache:(NSURL*) url thumbnailType:(ThumbnailType) thumbnailType
{
    UIImage* thumbnail = nil;
    NSMutableString* cachedKey = [NSMutableString string];
    
    if (nil != url)
    {
        NSString* originPicCachedKey = [self cacheKeyForURL:url];
        
        switch (thumbnailType)
        {
            case SeedListTableCellThumbnail:
            {
                [cachedKey appendString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDLISTTABLECELL];
                [cachedKey appendString:originPicCachedKey];
                break;
            }
            case SeedPictureCollectionCellThumbnail:
            {
                [cachedKey appendString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTURECOLLECTIONCELL];
                [cachedKey appendString:originPicCachedKey];
                break;
            }
            case SeedPictureViewThumbnail:
            {
                [cachedKey appendString:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTUREVIEW];
                [cachedKey appendString:originPicCachedKey];
                break;
            }
            default:
            {
                break;
            }
        }
        
        if (0 < cachedKey.length)
        {
            thumbnail = [_imageCache imageFromMemoryCacheForKey:cachedKey];
            thumbnail = (nil != thumbnail) ? thumbnail : [_imageCache imageFromDiskCacheForKey:cachedKey];
        }
    }
    
    return thumbnail;
}

-(void) prefetchSeedImages:(NSArray*) seedList
{
    NSAssert(nil != seedList, @"Illegal seed list");
    
    NSMutableArray* urls = [NSMutableArray arrayWithCapacity:seedList.count];
    for (Seed* seed in seedList)
    {
        NSArray* pictures = seed.seedPictures;
        for (SeedPicture* picture in pictures)
        {
            NSString* picLink = picture.pictureLink;
            NSURL* url = [NSURL URLWithString:picLink];
            [urls addObject:url];
        }
    }
    
    SDWebImagePrefetcher* imagePrefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    imagePrefetcher.maxConcurrentDownloads = 50;
    [imagePrefetcher prefetchURLs:urls completed:^(NSUInteger finishedCount, NSUInteger skippedCount)
     {
         NSString* majorStatus = @"Images Prefetched";
         NSMutableString* minorStatus = [NSMutableString string];
         [minorStatus appendString:@"Finished:"];
         [minorStatus appendString:[NSString stringWithFormat:@"%d", finishedCount]];
         [minorStatus appendString:@" "];
         [minorStatus appendString:@"Skipped:"];
         [minorStatus appendString:[NSString stringWithFormat:@"%d", skippedCount]];
         
         GUIModule* guiModule = [GUIModule sharedInstance];
         [guiModule showHUD:majorStatus minorStatus:minorStatus delay:2];
     }];
}


@end
