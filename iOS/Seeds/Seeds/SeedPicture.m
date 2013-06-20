//
//  SeedPicture.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPicture.h"

@implementation SeedPicture

@synthesize isPlaceHolder = _isPlaceHolder;

@synthesize pictureId = _pictureId;
@synthesize seedLocalId = _seedLocalId;
@synthesize seedId = _seedId;
@synthesize pictureLink = _pictureLink;
@synthesize memo = _memo;

+(SeedPicture*) placeHolder
{
    SeedPicture* picture = [[SeedPicture alloc] init];
    picture.isPlaceHolder = YES;
    return picture;
}

@end
