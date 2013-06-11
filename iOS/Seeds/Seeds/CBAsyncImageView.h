//
//  CBAsyncImageView.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-10.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircularProgressView.h"

@interface CBAsyncImageView : UIView <CircularProgressDelegate>
{	
}

@property (nonatomic, strong) CircularProgressView* circularProgressView;
@property (nonatomic, strong) id<CircularProgressDelegate> circularProgressDelegate;

- (void)loadImageFromURL:(NSURL*) url;
- (void)loadImageFromLocal:(UIImage*) image;
- (UIImage*) image;

@end
