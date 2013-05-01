//
//  SeedPictureScrollView.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-01.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeedPictureScrollViewDelegate;

@interface SeedPictureScrollView : UIScrollView

@property (assign, nonatomic) id<SeedPictureScrollViewDelegate> photoViewDelegate;

- (void)prepareForReuse;
- (void)displayImage:(UIImage *)image;

- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;

@end

@protocol SeedPictureScrollViewDelegate <NSObject>

@optional

- (void)pictureViewDidSingleTap:(SeedPictureScrollView *)photoView;
- (void)pictureViewDidDoubleTap:(SeedPictureScrollView *)photoView;
- (void)pictureViewDidTwoFingerTap:(SeedPictureScrollView *)photoView;
- (void)pictureViewDidDoubleTwoFingerTap:(SeedPictureScrollView *)photoView;

@end