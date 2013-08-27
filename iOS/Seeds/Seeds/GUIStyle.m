//
//  GUIStyle.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "GUIStyle.h"

#import <QuartzCore/QuartzCore.h>

#import "FlatUIKit.h"

@implementation GUIStyle

// Static block
+(void) initialize
{
}

+(void) formatUIImageView:(UIImageView *)imageView
{
    if (nil != imageView)
    {
//        UIImageView* _imageView = imageView;
        
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
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

+(void) formatFlatUIButton:(FUIButton*) button buttonColor:(UIColor*) buttonColor shadowColor:(UIColor*) shadowColor shadowHeight:(CGFloat) shadowHeight cornerRadius:(CGFloat) cornerRadius titleColor:(UIColor*) titleColor highlightedTitleColor:(UIColor*) highlightedTitleColor
{
    if (button)
    {
        button.buttonColor = buttonColor;
        button.shadowColor = shadowColor;
        button.shadowHeight = shadowHeight;
        button.cornerRadius = cornerRadius;
        #warning FlatUIKit Issue?
        // button.titleLabel.font = [UIFont flatFontOfSize:24];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        [button setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
    }
}

+(void) formatFlatUILabel:(UILabel*) label
{
    if (label)
    {
        label.textColor = FLATUI_COLOR_BUTTON_TEXT;
    }
}

+(void) formatFlatUIProgressView:(UIProgressView*) progress
{
    if (progress)
    {
        [progress configureFlatProgressViewWithTrackColor:FLATUI_COLOR_PROGRESS_TRACK progressColor:FLATUI_COLOR_PROGRESS];
    }
}

+(void) formatFlatUINavigationBar:(UINavigationBar*) navigationBar
{
    if (navigationBar)
    {
        [navigationBar configureFlatNavigationBarWithColor:FLATUI_COLOR_NAVIGATIONBAR];
        navigationBar.titleTextAttributes = @{//UITextAttributeFont: [UIFont boldFlatFontOfSize:18],
                                                                        UITextAttributeTextColor: [UIColor whiteColor]};
    }
}

+(void) formatFlatUIBarButtonItem:(UIBarButtonItem*) buttonItem
{
    if (buttonItem)
    {
        [buttonItem configureFlatButtonWithColor:FLATUI_COLOR_BARBUTTONITEM highlightedColor:FLATUI_COLOR_BARBUTTONITEM_HIGHLIGHTED cornerRadius:FLATUI_CORNER_RADIUS];
        [buttonItem removeTitleShadow];
    }
}

+(void) formatFlatUIToolbar:(UIToolbar*) toolbar
{
    if (toolbar)
    {
        [toolbar configureFlatToolbarWithColor:FLATUI_COLOR_TOOLBAR];
    }
}

+(void) formatFlatUITableViewCell:(UITableViewCell*) cell backColor:(UIColor*) backColor selectedBackColor:(UIColor*) selectedBackColor
{
    if (cell)
    {
        [cell configureFlatCellWithColor:backColor selectedColor:selectedBackColor];
    }
}

@end
