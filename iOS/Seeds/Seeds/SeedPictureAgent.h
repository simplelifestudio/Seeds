//
//  SeedPictureAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDWebImageManager.h"

typedef enum {ListTableCellThumbnail = 0, PictureCollectionCellThumbnail, PictureViewThumbnail, PictureViewFullImage} SeedImageType;

typedef enum {EmptyImage = 0, ErrorImage} ImageExceptionType;

typedef void(^ImageDownloadInProgressBlock)(NSUInteger receivedSize, long long expectedSize);
typedef void(^ImageDownloadFinishBlock)(UIImage* image, SeedImageType imageType, NSError* error, SDImageCacheType cacheType, BOOL finished);

@interface SeedPictureAgent : NSObject <CBSharedInstance>

+(UIImage*)exceptionImageWithImagelType:(SeedImageType) imageType imageExceptionType:(ImageExceptionType) imageExceptionType;

+(UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize;

-(void) setMaxConcurrentDownloads:(NSUInteger) number;
-(void) setDownloadOptions:(SDWebImageOptions) options;
-(void) setMaxCahceAge:(NSUInteger) age;

-(void) queueRequest:(NSString*) urlPath imageType:(SeedImageType) imageType inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock;
-(void) queueRequest:(NSString *)urlPath imageType:(SeedImageType) imageType completeBlock:(ImageDownloadFinishBlock)completeBlock;

-(void) queueURLRequest:(NSURL*) url imageType:(SeedImageType) imageType inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock;
-(void) queueURLRequest:(NSURL*) url imageType:(SeedImageType) imageType completeBlock:(ImageDownloadFinishBlock)completeBlock;

-(void) clearThumbnailCacheKeys;
-(void) saveThumbnailCacheKeys;

-(void) cacheImages:(UIImage*) image url:(NSURL*) url;
-(UIImage*) imageFromCache:(NSURL*) url imageType:(SeedImageType) imageType;

-(void) clearMemory;
-(void) clearCacheBothInMemoryAndDisk;

-(void) cleanExpiredCache;

- (unsigned long long) diskCacheImagesSize;
- (NSUInteger) diskCacheImagesCount;

-(BOOL) isLoadFailedSeedPicture:(SeedPicture*) picture;
-(void) addFailedSeedPicture:(SeedPicture*) picture;
-(void) removeFailedSeedPicture:(SeedPicture*) picture;

-(BOOL) isLoadFailedURL:(NSURL*) url;
-(void) addFailedURL:(NSURL*) url;
-(void) removeFailedURL:(NSURL*) url;

-(void) prefetchSeedImages:(NSArray*) seedList;

@end
