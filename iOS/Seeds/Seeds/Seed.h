//
//  Seed.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPicture.h"

@interface Seed : NSObject

@property (nonatomic) NSInteger seedId;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) NSString* publishDate;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* size;
@property (nonatomic, strong) NSString* format;
@property (nonatomic, strong) NSString* torrentLink;
@property (nonatomic) BOOL favorite;
@property (nonatomic, strong) NSString* hash;
@property (nonatomic) BOOL mosaic;
@property (nonatomic, strong) NSString* memo;

@property (nonatomic, strong) NSMutableArray* seedPictures;

@end
