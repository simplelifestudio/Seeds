//
//  ServerAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "JSONMessage.h"
#import "JSONMessageDelegate.h"

@interface ServerAgent : NSObject <JSONMessageDelegate>

@property (nonatomic, strong) id<CBLongTaskStatusHUDDelegate> delegate;

+(NSMutableURLRequest*) constructURLRequest:(JSONMessage*) message;

-(void) aloha;
-(void) seedsUpdateStatusByDates:(NSArray*) dates;
-(void) seedsByDates:(NSArray*) dates;
-(void) seedsToCart:(NSArray*) seedIds;

-(void) syncSeedsInfo;

@end