//
//  GUIStyle.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIStyle.h"

#import <QuartzCore/QuartzCore.h>

@implementation GUIStyle

// Static block
+(void) initialize
{
}

+(void) formatUIImageView:(UIImageView *)imageView
{
    if (nil != imageView)
    {
        UIImageView* _imageView = imageView;
        
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
//        //添加边框
//        CALayer * layer = [_imageView layer];
//        layer.borderColor = [[UIColor whiteColor] CGColor];
//        layer.borderWidth = 2.0f;
//        //添加四个边阴影
//        _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//        _imageView.layer.shadowOffset = CGSizeMake(0, 0);
//        _imageView.layer.shadowOpacity = 0.5;
//        _imageView.layer.shadowRadius = 10.0;//给iamgeview添加阴影 < wbr > 和边框
//        //添加两个边阴影
//        _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//        _imageView.layer.shadowOffset = CGSizeMake(4, 4);
//        _imageView.layer.shadowOpacity = 0.5;
//        _imageView.layer.shadowRadius = 2.0;
    }
}

@end
