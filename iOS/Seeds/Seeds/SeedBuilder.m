//
//  SeedBuilder.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedBuilder.h"

@interface SeedBuilder()
{
    Seed* _seed;
}

@end

@implementation SeedBuilder

+(BOOL) verfiySeed:(Seed*) seed
{
    BOOL flag = NO;
    
    flag =  (nil != seed && nil != seed.name && 0 < seed.name.length && nil != seed.torrentLink && 0 < seed.torrentLink.length) ? YES : NO;
    
    return flag;
}

-(void) initSeed
{
    _seed = [[Seed alloc] init];
}

-(void) resetSeed
{
    [self initSeed];
}

-(void) fillSeedWithAttribute:(NSString*) attrName attrVal:(NSString*)attrVal
{
    if (nil != attrName && 0 < attrName.length && nil != attrVal && 0 < attrVal.length)
    {
        if ([attrName isEqualToString:TABLE_SEED_COLUMN_NAME])
        {
            [_seed setName:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_FORMAT])
        {
            [_seed setFormat:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_SIZE])
        {
            [_seed setSize:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_MOSAIC])
        {
            BOOL flag1 = nil != attrVal;
            BOOL flag2 = [CBStringUtils isSubstringIncluded:attrVal subString:@"无"];
            BOOL flag3 = [CBStringUtils isSubstringIncluded:attrVal subString:@"無"];
            BOOL mosaic = (flag1 && (flag2 | flag3)) ? NO : YES;
            [_seed setMosaic:mosaic];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_HASH])
        {
            [_seed setHash:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_TORRENTLINK])
        {
            [_seed setTorrentLink:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEEDPICTURE_COLUMN_PICTURELINK])
        {
            SeedPicture* picture = [[SeedPicture alloc] init];
            picture.pictureLink = attrVal;
            
            [_seed.seedPictures addObject:picture];
        }
    }
}

-(BOOL) isSeedReady
{
    return [SeedBuilder verfiySeed:_seed];
}

-(Seed*) getSeed
{
    Seed* tempSeed = nil;
    if ([self isSeedReady])
    {
        tempSeed = _seed;
    }
    else
    {
//        DLog(@"Seed object in builder is illegal: %@", seed);
    }
    
    [self resetSeed];
    return tempSeed;
}

@end
