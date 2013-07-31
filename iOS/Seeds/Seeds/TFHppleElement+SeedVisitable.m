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
    BOOL flag1 = [CBStringUtils isSubstringIncluded:content subString:@"影片格式"];
    BOOL flag2 = [CBStringUtils isSubstringIncluded:content subString:@"文件類型"];
    BOOL flag3 = [CBStringUtils isSubstringIncluded:content subString:@"文件类型"];
    BOOL flag4 = [CBStringUtils isSubstringIncluded:content subString:@"格式类型"];
    BOOL flag5 = [CBStringUtils isSubstringIncluded:content subString:@"格式類型"];
    flag = (flag1 | flag2 | flag3 | flag4 | flag5);    
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
    BOOL flag5 = [CBStringUtils isSubstringIncluded:content subString:@"有／無碼"];
    BOOL flag6 = [CBStringUtils isSubstringIncluded:content subString:@"影片類別"];
    BOOL flag7 = [CBStringUtils isSubstringIncluded:content subString:@"檔案類別"];
    flag = (flag1 | flag2 | flag3 | flag4 | flag5 | flag6 | flag7);
    return flag;
}

-(BOOL) isSeedHashNode
{    
    BOOL flag = NO;
    NSString* content = self.content;
    BOOL flag1 = [CBStringUtils isSubstringIncluded:content subString:@"验证徵码"];
    BOOL flag2 = [CBStringUtils isSubstringIncluded:content subString:@"驗證號碼"];
    BOOL flag3 = [CBStringUtils isSubstringIncluded:content subString:@"特 征 码"];
    BOOL flag4 = [CBStringUtils isSubstringIncluded:content subString:@"特征编码"];
    BOOL flag5 = [CBStringUtils isSubstringIncluded:content subString:@"驗證全碼"];
    BOOL flag6 = [CBStringUtils isSubstringIncluded:content subString:@"验证编码"];
    BOOL flag7 = [CBStringUtils isSubstringIncluded:content subString:@"哈 希 校"];
    BOOL flag8 = [CBStringUtils isSubstringIncluded:content subString:@"哈希"];
    flag = (flag1 | flag2 | flag3 | flag4 | flag5 | flag6 | flag7 | flag8);
    return flag;
}

-(BOOL) isSeedTorrentLinkNode
{
    BOOL flag = NO;

    flag = [self.tagName isEqualToString:@"a"];
    if (flag)
    {
        NSString* attrVal = [self parseSeedTorrentLink];
        flag = [CBStringUtils isSubstringIncluded:attrVal subString:BASEURL_TORRENTSTORE];
    }
    return flag;
}

-(BOOL) isSeedPictureLinkNode
{
    BOOL flag = NO;
    flag = [self.tagName isEqualToString:@"img"];
    return flag;
}

-(NSString*) parseContent
{
    NSString* content = self.content;
    
    content = [self _parseHeaderContent:content];
    
    content = [self _parseContent:content];
    
    return content;
}

-(NSString*) _parseContent:(NSString*) content
{    
    NSRange range = [content rangeOfString:STR_COLON_FULLWIDTH_1];
    NSInteger rangeLocation = range.location + 1;
    if (0 < range.length && content.length > rangeLocation)
    {
        content = [content substringFromIndex:rangeLocation];
        content = [CBStringUtils trimString:content];
        
        return [self _parseContent:content];
    }
    
    range = [content rangeOfString:STR_COLON_FULLWIDTH_2];
    rangeLocation = range.location + 1;
    if (0 < range.length && content.length > rangeLocation)
    {
        content = [content substringFromIndex:rangeLocation];
        content = [CBStringUtils trimString:content];
        
        return [self _parseContent:content];        
    }
    
    range = [content rangeOfString:STR_COLON];
    rangeLocation = range.location + 1;
    if (0 < range.length && content.length > rangeLocation)
    {
        content = [content substringFromIndex:rangeLocation];
        content = [CBStringUtils trimString:content];
        
        return [self _parseContent:content];        
    }
    
    range = [content rangeOfString:STR_BRACKET_RIGHT_1];
    rangeLocation = range.location + 1;    
    if (0 < range.length && content.length > rangeLocation)
    {
        content = [content substringFromIndex:rangeLocation];
        content = [CBStringUtils trimString:content];
        
        return [self _parseContent:content];        
    }
    
    range = [content rangeOfString:STR_BRACKET_RIGHT_2];
    rangeLocation = range.location + 1;    
    if (0 < range.length && content.length > rangeLocation)
    {
        content = [content substringFromIndex:rangeLocation];
        content = [CBStringUtils trimString:content];
        
        return [self _parseContent:content];
    }
    
    return content;
}

-(NSString*) _parseHeaderContent:(NSString*) content
{
    NSRange range = [content rangeOfString:STR_COLON_FULLWIDTH_1];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }

        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_COLON_FULLWIDTH_2];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_COLON];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_BRACKET_LEFT_1];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_BRACKET_RIGHT_1];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_BRACKET_LEFT_2];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_BRACKET_RIGHT_2];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_RETURN];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    range = [content rangeOfString:STR_NEWLINE];
    if (0 == range.location)
    {
        NSInteger startLocation = range.location + 1;
        if (content.length > startLocation)
        {
            content = [content substringFromIndex:startLocation];
        }
        return [self _parseHeaderContent:content];
    }
    
    content = [CBStringUtils trimString:content];
    
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

-(NSString*) parseSeedMosaic
{
    return [self parseContent];
}

-(NSString*) parseSeedHash
{
    return [self parseContent];
}

-(NSString*) parseSeedTorrentLink
{
    NSString* link = [self.attributes valueForKey:@"href"];
    return link;
}

-(NSString*) parseSeedPictureLink
{
    NSString* link = [self.attributes valueForKey:@"src"];
    return link;
}

@end
