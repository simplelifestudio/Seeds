//
//  SeedsSpider.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFHpple.h"
#import "MBProgressHUD.h"

#import "CBDateUtils.h"

#import "SeedsVisitor.h"
#import "ServerAgent.h"

@interface SeedsSpider : NSObject

@property (nonatomic, strong) id<CBLongTaskStatusHUDDelegate> seedsSpiderDelegate;

-(NSString*) pullSeedListLinkByDate:(NSDate*) date;
-(NSArray*) pullSeedsFromLink:(NSString*) link;

-(void) pullSeedsInfo:(NSArray*) days;

@end
