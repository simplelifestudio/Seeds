//
//  AsyncImageView.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-10.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircularProgressView.h"

#import "SeedPictureAgent.h"

@interface AsyncImageView : UIView <CircularProgressDelegate>
{	
}

@property (nonatomic, strong) CircularProgressView* circularProgressView;
@property (nonatomic, strong) id<CircularProgressDelegate> circularProgressDelegate;
@property (nonatomic) SeedImageType imageType;

- (void)loadImageFromURL:(NSURL*) url imageType:(SeedImageType) imageType;
- (void)loadImageFromLocal:(UIImage*) image;
- (UIImage*) image;

- (void)removeOriginalImage;

@end
