//
//  SeedsVisitor.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsVisitor.h"

@implementation SeedsVisitor

@synthesize builder = _builder;

-(id) init
{
    self = [super init];
    if (self)
    {
        _builder = [[SeedBuilder alloc] init];
    }
    return self;
}

-(NSArray*) visitNodes:(NSArray*) elements;
{
    NSMutableArray* seedList = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != elements)
    {
        [_builder initSeed];
        for (TFHppleElement* element in elements)
        {
            if (nil != element && [element isKindOfClass:[TFHppleElement class]])
            {
                if ([element isTextNode])
                {
                    [self visitTextNode:element];
                }
                else if ([element isSeedTorrentLinkNode])
                {
                    [self visitAnchorNode:element];
                    
                    Seed* seed = [_builder getSeed];
                    if (nil != seed)
                    {
                        [seedList addObject:seed];
                    }
                    // Seed object ends                    
                }
                else if ([element isSeedPictureLinkNode])
                {
                    [self visitImageNode:element];
                }
            }
            else
            {
                DLog(@"Illegal element was found: %@", element);
            }
        }
    }
    
    return seedList;
}

-(void) visitTextNode:(TFHppleElement*) element
{
    if ([element isSeedNameNode])
    {
        // Seed object begins
        [_builder resetSeed];
        
        NSString* attrVal = [element parseSeedName];
        
        [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_NAME attrVal:attrVal];
    }
    else if ([element isSeedSizeNode])
    {
        NSString* attrVal = [element parseSeedSize];
        [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_SIZE attrVal:attrVal];
    }
    else if ([element isSeedFormatNode])
    {
        NSString* attrVal = [element parseSeedFormat];
        [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_FORMAT attrVal:attrVal];
    }
    else if ([element isSeedMosaicNode])
    {
        NSString* attrVal = [element parseSeedMosaic];
        [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_MOSAIC attrVal:attrVal];
    }
    else if ([element isSeedHashNode])
    {
        NSString* attrVal = [element parseSeedHash];
        [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_HASH attrVal:attrVal];
    }    
}

-(void) visitImageNode:(TFHppleElement*) element
{
    NSString* attrVal = [element parseSeedPictureLink];
    [_builder fillSeedWithAttribute:TABLE_SEEDPICTURE_COLUMN_PICTURELINK attrVal:attrVal];
}

-(void) visitAnchorNode:(TFHppleElement*) element
{
    NSString* attrVal = [element parseSeedTorrentLink];
    [_builder fillSeedWithAttribute:TABLE_SEED_COLUMN_TORRENTLINK attrVal:attrVal];
}

@end
