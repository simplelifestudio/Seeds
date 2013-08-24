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

#import "SeedPictureAgent.h"
#import "SeedsDownloadAgent.h"

typedef void(^JSONMessageCallBackBlock)(id JSON, NSError* error);

@interface ServerAgent : NSObject <JSONMessageDelegate>

@property (nonatomic, strong) SeedPictureAgent* pictureAgent;
@property (nonatomic, strong) SeedsDownloadAgent* downloadAgent;

@property (nonatomic, strong) id<CBLongTaskStatusHUDDelegate> delegate;

+(NSMutableURLRequest*) constructURLRequest:(JSONMessage*) message serverServiceType:(ServerServiceType) serverServiceType;
+(NSArray*) seedsFromDictionary:(NSArray*) seedDics;
+(Seed*) seedFromDictionary:(NSDictionary*) seedDic;

#pragma mark - Async Invocations
-(void) aloha:(JSONMessageCallBackBlock) callbackBlock;
-(void) seedsUpdateStatusByDates:(JSONMessageCallBackBlock) callbackBlock;
-(void) seedsByDates:(JSONMessageCallBackBlock) callbackBlock;
-(void) seedsToCart:(NSString*) cartId seedIds:(NSArray*) seedIds callbackBlock:(JSONMessageCallBackBlock) callbackBlock;

#pragma mark - Sync Invocations
-(JSONMessage*) alohaRequest;
-(JSONMessage*) seedsUpdateStatusByDatesRequest:(NSArray*) days;
-(JSONMessage*) seedsByDatesRequest:(NSArray*) days;
-(JSONMessage*) seedsToCartRequest:(NSString*) cartId seedIds:(NSArray*) seedIds;
-(JSONMessage*) newCartIdRequest;
-(NSString*) newCartId;

-(void) syncSeedsInfo;

@end