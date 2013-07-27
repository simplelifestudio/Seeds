//
//  SeedsSpider.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFHpple.h"

#import "CBDateUtils.h"

#import "SeedsVisitor.h"
#import "ServerAgent.h"

@interface SeedsSpider : NSObject

@property (nonatomic, strong) id<CBLongTaskStatusHUDDelegate> seedsSpiderDelegate;

-(NSString*) pullSeedListLinkByDate:(NSDate*) date error:(__autoreleasing NSError**)errorPtr;
-(NSArray*) pullSeedsFromLink:(NSString*) link error:(__autoreleasing NSError**)errorPtr;

-(void) pullSeedsInfo:(NSArray*) days;

@end
