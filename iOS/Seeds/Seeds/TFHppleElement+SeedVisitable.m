//
//  TFHppleElement+SeedVisitable.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TFHppleElement+SeedVisitable.h"

@implementation TFHppleElement (SeedVisitable)

-(BOOL) isSeedNameNode
{
    BOOL flag = NO;
    NSString* content = self.content;
    flag = [CBStringUtils isSubstringIncluded:content subString:@"片名"];
    return flag;
}

-(BOOL) isSeedSizeNode
{
    BOOL flag = NO;
    NSString* content = self.content;
    flag = [CBStringUtils isSubstringIncluded:content subString:@"大小"];
    return flag;
}

-(BOOL) isSeedFormatNode
{
    BOOL flag = NO;
    NSString* content = self.content;
    flag = [CBStringUtils isSubstringIncluded:content subString:@"格式"];
    return flag;
}

-(BOOL) isSeedMosaicNode
{
    BOOL flag = NO;
    NSString* content = self.content;
    BOOL flag1 = [CBStringUtils isSubstringIncluded:content subString:@"有碼無碼"];
    BOOL flag2 = [CBStringUtils isSubstringIncluded:content subString:@"有码无码"];
    BOOL flag3 = [CBStringUtils isSubstringIncluded:content subString:@"是否有碼"];
    BOOL flag4 = [CBStringUtils isSubstringIncluded:content subString:@"是否有码"];
    flag = (flag1 | flag2 | flag3 | flag4);    
    return flag;
}

-(BOOL) isSeedTorrentLinkNode
{
    BOOL flag = NO;
    NSString* content = self.content;    
    flag = [CBStringUtils isSubstringIncluded:content subString:@"http://www.maxp2p.com/link.php?ref="];
    return flag;
}

-(NSString*) parseContent
{
    NSString* content = self.content;
    
    NSRange range = [content rangeOfString:STR_COLON_FULLWIDTH];
    if (0 < range.length)
    {
        content = [content substringFromIndex:range.location + 1];
        content = [CBStringUtils trimString:content];
        return content;
    }
    
    range = [content rangeOfString:STR_BRACKET_RIGHT];
    if (0 < range.length)
    {
        content = [content substringFromIndex:range.location + 1];
        content = [CBStringUtils trimString:content];
        return content;
    }
    
    return content;
}

-(NSString*) parseSeedName
{
    return [self parseContent];
}

-(NSString*) parseSeedSize
{
    return [self parseContent];
}

-(NSString*) parseSeedFormat
{
    return [self parseContent];
}

-(NSString*) parseSeedTorrentLink
{
    return [self parseContent];
}

-(NSString*) parseSeedMosaic
{
    return [self parseContent];
}

@end
