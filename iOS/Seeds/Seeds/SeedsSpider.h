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

#import "MBProgressHUD.h"

#define SEEDLIST_LINK_DATE_FORMAT @"M-dd"

@protocol SeedsSpiderDelegate <NSObject>

-(void) spiderStarted:(NSString*) majorStatus;
-(void) spiderIsProcessing:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;
-(void) spiderFinished:(NSString*) majorStatus;

@end

@interface SeedsSpider : NSObject

@property (nonatomic, strong) id<SeedsSpiderDelegate> delegate;

-(NSString*) pullSeedListLinkByDate:(NSDate*) date;
-(NSArray*) pullSeedsFromLink:(NSString*) link;

-(void) pullSeedsInfo;

@end
