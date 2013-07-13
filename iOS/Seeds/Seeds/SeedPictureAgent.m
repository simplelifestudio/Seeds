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
    UserDefaultsModule* _userDefaults;
    
    SDWebImageManager* _imageManager;
    SDWebImageOptions _downloadOptions;
    SDImageCache* _imageCache;
    
    NSMutableDictionary* _thumbnailCacheKeys;
    SDImageCache* _listTableCellThumbnailCache;
    SDImageCache* _pictureCollectionCellThumbnailCache;
    SDImageCache* _pictureViewThumbnailCache;
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

+(UIImage*)exceptionImageWithImagelType:(SeedImageType) imageType imageExceptionType:(ImageExceptionType) imageExceptionType;
{
    UIImage* image = nil;
    
    switch (imageType)
    {
        case ListTableCellThumbnail:
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
        case PictureCollectionCellThumbnail:
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
        case PictureViewThumbnail:
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
        case PictureViewFullImage:
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
//        DLog(@"Image is smaller than thumbnail which is being converted.");
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
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    _imageManager = [SDWebImageManager new];
    _imageCache = _imageManager.imageCache;

    _thumbnailCacheKeys = [NSMutableDictionary dictionary];
    _listTableCellThumbnailCache = [[SDImageCache alloc] initWithNamespace:CACHEKEY_SUFFIX_THUMBNAIL_SEEDLISTTABLECELL];
    _pictureCollectionCellThumbnailCache = [[SDImageCache alloc] initWithNamespace:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTURECOLLECTIONCELL];
    _pictureViewThumbnailCache = [[SDImageCache alloc] initWithNamespace:CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTUREVIEW];
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

-(void) queueRequest:(NSString*) urlPath imageType:(SeedImageType) imageType inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock
{
    if(nil == urlPath)
    {
        DLog(@"Null url path");
        return;
    }
    
    NSURL* url = [NSURL URLWithString:urlPath];
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        UIImage* cachedImage = [self imageFromCache:url imageType:imageType];
        if (nil != cachedImage)
        {
            [CBAppUtils asyncProcessInBackgroundThread:^(){
                completeBlock(cachedImage, imageType, nil, SDImageCacheTypeDisk, YES);
            }];
        }
        else
        {
            BOOL is3GDownloadImagesEnabled = [_userDefaults isDownloadImagesThrough3GEnabled];
            BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
            BOOL downLoadImagesThroughInternet = (is3GDownloadImagesEnabled || isWiFiEnabled);
            if (downLoadImagesThroughInternet)
            {
                [_imageManager downloadWithURL:url options:_downloadOptions progress:inProgressBlock completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                    completeBlock(image, imageType, error, cacheType, finished);
                }];
            }
            else
            {
                [CBAppUtils asyncProcessInBackgroundThread:^(){
                    NSURL* url = [NSURL URLWithString:urlPath];
                    NSString* key = [self cacheKeyForURL:url];
                    [_imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType){
                        BOOL finished = (nil != image) ? YES : NO;
                        completeBlock(image, imageType, nil, cacheType, finished);
                    }];
                    
                    [CBAppUtils asyncProcessInBackgroundThread:^(){
                        [self clearMemory];
                    }];
                }];
            }
        }
    }];
}

-(void) queueRequest:(NSString *)urlPath imageType:(SeedImageType) imageType completeBlock:(ImageDownloadFinishBlock)completeBlock
{
    [self queueRequest:urlPath imageType:imageType inProgressBlock:nil completeBlock:completeBlock];
}

-(void) queueURLRequest:(NSURL*) url imageType:(SeedImageType) imageType inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock
{
    if (nil == url)
    {
        DLog(@"Null url");
        return;
    }
    
    NSString* urlPath = url.absoluteString;
    [self queueRequest:urlPath imageType:imageType inProgressBlock:inProgressBlock completeBlock:completeBlock];
}

-(void) queueURLRequest:(NSURL*) url imageType:(SeedImageType) imageType completeBlock:(ImageDownloadFinishBlock)completeBlock
{
    [self queueURLRequest:url imageType:imageType inProgressBlock:nil completeBlock:completeBlock];
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

-(void) clearMemory
{
    [_pictureCollectionCellThumbnailCache clearMemory];
    [_imageCache clearMemory];
}

-(void) clearCacheBothInMemoryAndDisk
{
    @synchronized(_thumbnailCacheKeys)
    {
        [_thumbnailCacheKeys removeAllObjects];
        
        [_listTableCellThumbnailCache clearMemory];
        [_listTableCellThumbnailCache clearDisk];
        
        [_pictureCollectionCellThumbnailCache clearMemory];
        [_pictureCollectionCellThumbnailCache clearDisk];
        
        [_pictureViewThumbnailCache clearMemory];
        [_pictureViewThumbnailCache clearDisk];
        
        [_imageCache clearMemory];
        [_imageCache clearDisk];
    }
}

- (unsigned long long) diskCacheImagesSize
{
    return [_imageCache getSize];
}

- (NSUInteger) diskCacheImagesCount
{
    return [_imageCache getDiskCount];
}

-(BOOL) isURLInFailedList:(NSURL*) url
{
    return [_imageManager isURLInFailedList:url];
}

-(BOOL) isLoadFailedSeedPicture:(SeedPicture*) picture
{
    BOOL flag = NO;
    
    if (nil != picture && picture.pictureLink && 0 < picture.pictureLink.length)
    {
        NSURL* url = [NSURL URLWithString:picture.pictureLink];
        flag = [_imageManager isURLInFailedList:url];
    }
    
    return flag;
}

-(void) removeFailedSeedPicture:(SeedPicture *)picture
{
    if (nil != picture && nil != picture.pictureLink)
    {
        NSURL* url = [NSURL URLWithString:picture.pictureLink];
        [_imageManager removeFailedURL:url];
    }
}

-(void) cacheImages:(UIImage*) image url:(NSURL*) url
{
//    DLog(@"Image's size is: %f, %f", image.size.width, image.size.height);
    @synchronized(_thumbnailCacheKeys)
    {
        NSString* cacheKey = [self cacheKeyForURL:url];
        id hasKey = [_thumbnailCacheKeys objectForKey:cacheKey];
        if (nil == hasKey)
        {
            [self _saveCacheImage:url image:image imageType:ListTableCellThumbnail];
            [self _saveCacheImage:url image:image imageType:PictureCollectionCellThumbnail];
            [self _saveCacheImage:url image:image imageType:PictureViewThumbnail];
            [self _saveCacheImage:url image:image imageType:PictureViewFullImage];
            
            [_thumbnailCacheKeys setObject:url forKey:cacheKey];
        }
    }
}

-(UIImage*) imageFromCache:(NSURL*) url imageType:(SeedImageType) imageType
{
    UIImage* image = nil;
    
    @synchronized(_thumbnailCacheKeys)
    {
        NSString* cacheKey = [self cacheKeyForURL:url];
        id hasKey = [_thumbnailCacheKeys objectForKey:cacheKey];
        if (nil != hasKey)
        {
            image = [self _readCacheImage:url imageType:imageType];
        }
    }
    
    return image;
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(_appDidEnterBackground)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(connectionDidDie:)
//                                                 name:HTTPConnectionDidDieNotification
//                                               object:nil];

    SDWebImagePrefetcher* imagePrefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    imagePrefetcher.options = SDWebImageRetryFailed;
    imagePrefetcher.maxConcurrentDownloads = SEEDPICTURE_PREFETCHER_MAX_CONCURRENT_DOWNLOADS;
    [imagePrefetcher prefetchURLs:urls completed:^(NSUInteger finishedCount, NSUInteger skippedCount){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ID_SEEDPICTUREPREFETCH_FINISHED object:self userInfo:nil];
     }];
}

-(UIImage*) _readCacheImage:(NSURL*) url imageType:(SeedImageType) imageType
{
    NSAssert(nil != url, @"Nil URL");

    UIImage* image = nil;

    NSString* cacheKey = [self cacheKeyForURL:url];    
    
    switch (imageType)
    {
        case ListTableCellThumbnail:
        {
            image = [_listTableCellThumbnailCache imageFromDiskCacheForKey:cacheKey];
            break;
        }
        case PictureCollectionCellThumbnail:
        {
            image = [_pictureCollectionCellThumbnailCache imageFromDiskCacheForKey:cacheKey];
            break;
        }
        case PictureViewThumbnail:
        {
//            image = [_pictureViewThumbnailCache imageFromDiskCacheForKey:cacheKey];
            break;
        }
        case PictureViewFullImage:
        {
//            image = [_imageCache imageFromDiskCacheForKey:cacheKey];
            break;
        }
        default:
        {
            break;
        }
    }

    return image;
}

-(void) _saveCacheImage:(NSURL*) url image:(UIImage*) image imageType:(SeedImageType) imageType;
{
    NSAssert(nil != url, @"Nil URL");
    NSAssert(nil != image, @"Nil Image");
    
    NSString* cacheKey = [self cacheKeyForURL:url];

    switch (imageType)
    {
        case ListTableCellThumbnail:
        {
            image = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDLISTTABLECELL];
            [_listTableCellThumbnailCache storeImage:image forKey:cacheKey];
            break;
        }
        case PictureCollectionCellThumbnail:
        {
            image = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDPICTURECOLLECTIONCELL];
            [_pictureCollectionCellThumbnailCache storeImage:image forKey:cacheKey];
            break;
        }
        case PictureViewThumbnail:
        {
//            image = [SeedPictureAgent thumbnailOfImage:image withSize:THUMBNAIL_SIZE_SEEDPICTUREVIEW];
//            [_pictureViewThumbnailCache storeImage:image forKey:cacheKey];
            break;
        }
        case PictureViewFullImage:
        {
            // Do nothing as SDWebImageManager will take this condition
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
