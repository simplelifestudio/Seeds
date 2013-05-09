//
//  Seed.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "Seed.h"

@implementation Seed

@synthesize seedId = _seedId;
@synthesize type = _type;
@synthesize source = _source;
@synthesize publishDate = _publishDate;
@synthesize name = _name;
@synthesize size = _size;
@synthesize format = _format;
@synthesize torrentLink = _torrentLink;
@synthesize favorite = _favorite;
@synthesize hash = _hash;
@synthesize mosaic = _mosaic;
@synthesize memo = _memo;

@synthesize seedPictures = _seedPictures;

-(id) init
{
    self = [super init];
    if (self)
    {
        _seedPictures = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

@end
