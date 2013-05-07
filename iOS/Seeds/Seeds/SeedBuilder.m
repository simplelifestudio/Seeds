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
    Seed* seed;
}

@end

@implementation SeedBuilder

-(void) initSeed
{
    seed = [[Seed alloc] init];
}

-(void) resetSeed
{
    [self initSeed];
}

-(void) fillSeedWithAttribute:(NSString*) attrName attrVal:(NSString*)attrVal
{
    if (nil != attrName && 0 < attrName.length && nil != attrVal)
    {
        if ([attrName isEqualToString:TABLE_SEED_COLUMN_NAME])
        {
            [seed setName:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_FORMAT])
        {
            [seed setFormat:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_SIZE])
        {
            [seed setSize:attrVal];
        }
        else if ([attrName isEqualToString:TABLE_SEED_COLUMN_TORRENTLINK])
        {
            [seed setTorrentLink:attrVal];
        }
    }
}

-(BOOL) isSeedReady
{
    BOOL flag = NO;
    flag =  (nil != seed && nil != seed.name && nil != seed.torrentLink) ? YES : NO;
    return flag;
}

-(Seed*) getSeed
{
    Seed* tempSeed = nil;
    if ([self isSeedReady])
    {
        tempSeed = seed;
    }
    else
    {
        DLog(@"Seed in builder is illegal: %@", seed);
    }
    
    [self resetSeed];
    return tempSeed;
}

@end
