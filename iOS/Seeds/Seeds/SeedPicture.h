//
//  SeedPicture.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

@interface SeedPicture : NSObject

@property (nonatomic) BOOL isPlaceHolder;

@property (nonatomic) NSInteger pictureId;
@property (nonatomic) NSInteger seedId;
@property (nonatomic, strong) NSString* pictureLink;
@property (nonatomic, strong) NSString* memo;

+(SeedPicture*) placeHolder;

@end
