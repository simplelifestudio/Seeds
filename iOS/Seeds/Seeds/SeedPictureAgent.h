//
//  SeedPictureAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDWebImageManager.h"

typedef enum {EmptyImage = 0, ErrorImage} ImageExceptionType;

typedef enum {SeedListTableCellThumbnail = 0, SeedPictureCollectionCellThumbnail, SeedPictureViewThumbnail} ThumbnailType;

typedef void(^ImageDownloadInProgressBlock)(NSUInteger receivedSize, long long expectedSize);
typedef void(^ImageDownloadFinishBlock)(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished);

@interface SeedPictureAgent : NSObject <CBSharedInstance>

+(UIImage*)exceptionImageWithThumbnailType:(ThumbnailType) thumbnailType imageExceptionType:(ImageExceptionType) imageExceptionType;

+(UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize;

-(void) setMaxConcurrentDownloads:(NSUInteger) number;
-(void) setDownloadOptions:(SDWebImageOptions) options;

-(void) queueRequest:(NSString*) urlPath inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock;
-(void) queueRequest:(NSString *)urlPath completeBlock:(ImageDownloadFinishBlock)completeBlock;

-(void) queueURLRequest:(NSURL*) url inProgressBlock:(ImageDownloadInProgressBlock) inProgressBlock completeBlock:(ImageDownloadFinishBlock) completeBlock;
-(void) queueURLRequest:(NSURL*) url completeBlock:(ImageDownloadFinishBlock)completeBlock;

@end
