//
//  CBStringUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBStringUtils.h"

@implementation CBStringUtils

+(BOOL) isSubstringIncluded:(NSString*) parentString subString:(NSString*)subString
{
    BOOL flag = NO;
    
    if (nil != subString && nil != parentString)
    {
        NSRange range = [parentString rangeOfString:subString];
        if (0 < range.length)
        {
            flag = YES;
        }
    }
    
    return flag;
}

+(NSString*) trimString:(NSString*) string
{
    if (nil != string)
    {
        unichar spaceChar = ' ';
        unichar nbspChar = 160;
        
        unichar c;
        while (0 < string.length)
        {
            c = [string characterAtIndex:0];
            if (c == spaceChar || c == nbspChar)
            {
                string = [string substringFromIndex:1];
            }
            else
            {
                break;
            }
        }
        
        while (1 < string.length)
        {
            c = [string characterAtIndex:string.length - 1];
            if (c == spaceChar || c == nbspChar)
            {
                string = [string substringToIndex:string.length - 1];
            }
            else
            {
                break;
            }
        }
    }
    
    return string;
}

@end
