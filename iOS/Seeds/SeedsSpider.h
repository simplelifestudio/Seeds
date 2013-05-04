//
//  SeedsSpider.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBDateUtils.h"

#import "TFHpple.h"

@interface SeedsSpider : NSObject

-(NSString*) pullSeedListLinkByDate:(NSDate*) date;
-(NSArray*) pullSeedsFromLink:(NSString*) link;

-(void) pullSeedsInfo;

@end
