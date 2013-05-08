//
//  TFHppleElement+SeedVisitable.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TFHppleElement.h"

#import "CBStringUtils.h"

@interface TFHppleElement (SeedVisitable)

-(BOOL) isSeedNameNode;
-(BOOL) isSeedSizeNode;
-(BOOL) isSeedFormatNode;
-(BOOL) isSeedMosaicNode;
-(BOOL) isSeedHashNode;
-(BOOL) isSeedTorrentLinkNode;
-(BOOL) isSeedPictureLinkNode;

-(NSString*) parseSeedName;
-(NSString*) parseSeedSize;
-(NSString*) parseSeedFormat;
-(NSString*) parseSeedMosaic;
-(NSString*) parseSeedHash;
-(NSString*) parseSeedTorrentLink;
-(NSString*) parseSeedPictureLink;

-(NSString*) parseContent;

@end
