//
//  UIDevice+Resolutions.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "UIDevice+Resolutions.h"

@implementation UIDevice (Resolutions)

+ (UIDeviceResolution) currentResolution
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
            {
                return UIDevice_iPhoneStandardRes;
            }
            
            return (result.height > 960 ? UIDevice_iPhoneTallerHiRes : UIDevice_iPhoneHiRes);
        }
        else
        {
            return UIDevice_iPhoneStandardRes;
        }
    }
    else
    {
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
    }
}

+ (BOOL)isRunningOniPhone5
{
    if ([self currentResolution] == UIDevice_iPhoneTallerHiRes)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isRunningOniPhone
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL)isRunningOniOS6AndLater
{
    float version = [[UIDevice currentDevice] systemVersion].floatValue;
    BOOL flag = (6.0 <= version) ? YES : NO;
    return flag;
}

@end