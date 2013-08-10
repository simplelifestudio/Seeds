//
//  ServerAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "ServerAgent.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@interface ServerAgent()
{
    UserDefaultsModule* _userDefaults;
    id<SeedDAO> _seedDAO;
    CommunicationModule* _commModule;
    SeedsDownloadAgent* _downloadAgent;
    SeedPictureAgent* _pictureAgent;
}

@end

@implementation ServerAgent

@synthesize delegate = _delegate;

+(NSMutableURLRequest*) constructURLRequest:(JSONMessage*) message serverServiceType:(ServerServiceType)serverServiceType
{
    NSAssert(nil != message, @"Nil JSON Message");
    
    NSMutableURLRequest* request = nil;
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASEURL_SEEDSSERVER]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    
    switch (serverServiceType)
    {
        case SeedService:
        {
            request = [httpClient
                       requestWithMethod:@"POST"
                       path:REMOTEPATH_SEEDSERVICE
                       parameters:message.body];
            break;
        }
        case CartService:
        {
            request = [httpClient
                       requestWithMethod:@"POST"
                       path:REMOTEPATH_SEEDSERVICE
                       parameters:message.body];
            break;
        }
        default:
        {
            break;
        }
    }
    
    return request;
}

+(BOOL) _parseMosaicValue:(NSString*) mosaicStr
{
    BOOL flag1 = nil != mosaicStr;
    BOOL flag2 = [CBStringUtils isSubstringIncluded:mosaicStr subString:@"无"];
    BOOL flag3 = [CBStringUtils isSubstringIncluded:mosaicStr subString:@"無"];
    BOOL mosaic = (flag1 && (flag2 | flag3)) ? NO : YES;
    return mosaic;
}

+(NSArray*) seedsFromDictionary:(NSArray*) seedDics
{
    NSMutableArray* seeds = [NSMutableArray array];
    
    if (nil != seedDics)
    {
        for (NSDictionary* seedDic in seedDics)
        {
            Seed* seed = [ServerAgent seedFromDictionary:seedDic];
            if (nil != seed)
            {
                [seeds addObject:seed];
            }
        }
    }
    
    return seeds;
}

+(Seed*) seedFromDictionary:(NSDictionary*) seedDic
{
    Seed* seed = nil;
    
    if (nil != seedDic)
    {
        NSString* seedIdStr = [seedDic objectForKey:JSONMESSAGE_KEY_SEEDID];
        NSString* typeStr = [seedDic objectForKey:JSONMESSAGE_KEY_TYPE];
        NSString* sourceStr = [seedDic objectForKey:JSONMESSAGE_KEY_SOURCE];
        NSString* publishDateStr = [seedDic objectForKey:JSONMESSAGE_KEY_PUBLISHDATE];
        NSString* nameStr = [seedDic objectForKey:JSONMESSAGE_KEY_NAME];
        NSString* sizeStr = [seedDic objectForKey:JSONMESSAGE_KEY_SIZE];
        NSString* formatStr = [seedDic objectForKey:JSONMESSAGE_KEY_FORMAT];
        NSString* torrentLinkStr = [seedDic objectForKey:JSONMESSAGE_KEY_TORRENTLINK];
        NSString* mosaicStr = [seedDic objectForKey:JSONMESSAGE_KEY_MOSAIC];
        NSString* hashStr = [seedDic objectForKey:JSONMESSAGE_KEY_HASH];
        NSString* memoStr = [seedDic objectForKey:JSONMESSAGE_KEY_MEMO];
        
        seed = [[Seed alloc] init];
        seed.seedId = seedIdStr.integerValue;
        seed.type = typeStr;
        seed.source = sourceStr;
        seed.publishDate = publishDateStr;
        seed.name = nameStr;
        seed.size = sizeStr;
        seed.format = formatStr;
        seed.torrentLink = torrentLinkStr;
        seed.favorite = NO;
        seed.mosaic = [ServerAgent _parseMosaicValue:mosaicStr];
        seed.hash = hashStr;
        seed.memo = memoStr;
        
        NSArray* picLinks = [seedDic objectForKey:JSONMESSAGE_KEY_PICLINKS];
        NSMutableArray* pictures = [NSMutableArray array];
        for (NSString* picLink in picLinks)
        {
            SeedPicture* picture = [[SeedPicture alloc] init];
            picture.seedId = seed.seedId;
            picture.pictureLink = picLink;
            
            [pictures addObject:picture];
        }
        seed.seedPictures = pictures;
        
        BOOL isSeedLegal = [SeedBuilder verfiySeed:seed];
        if (!isSeedLegal)
        {
            DLog(@"Illegal seed after parsing from dictionary: %@", seed);
            
            seed = nil;
        }
    }
    
    return seed;
}

-(id) init
{
    self = [super init];
    
    if (nil != self)
    {
        _userDefaults = [UserDefaultsModule sharedInstance];
        _seedDAO = [DAOFactory getSeedDAO];
        
        _commModule = [CommunicationModule sharedInstance];
        _downloadAgent = _commModule.seedsDownloadAgent;
        _pictureAgent = _commModule.seedPictureAgent;
    }
    
    return self;
}

#pragma mark - Async Invocations

-(void) aloha:(JSONMessageCallBackBlock) callbackBlock
{
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@"Hello Seeds Server!"] forKeys:@[@"content"]];
    JSONMessage* message = [JSONMessage constructWithType:AlohaRequest messageBody:messageBody];
    [self requestAsync:SeedService
        requestMessage:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            callbackBlock(JSON, nil);
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            callbackBlock(JSON, error);
        }
     ];
}

-(void) seedsUpdateStatusByDates:(JSONMessageCallBackBlock) callbackBlock
{
    NSArray* _last3Days = [_userDefaults lastThreeDays];
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:_last3Days formatString:STANDARD_DATE_FORMAT];
    
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[last3DayStrs[0], last3DayStrs[1], last3DayStrs[2]]] forKeys:@[JSONMESSAGE_KEY_DATELIST]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsUpdateStatusByDatesRequest messageBody:messageBody];
    [self requestAsync:SeedService
        requestMessage:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            callbackBlock(JSON, nil);
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            callbackBlock(JSON, error);
        }];
}

-(void) seedsByDates:(JSONMessageCallBackBlock) callbackBlock
{
    NSArray* _last3Days = [_userDefaults lastThreeDays];
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:_last3Days formatString:STANDARD_DATE_FORMAT];
    
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[last3DayStrs[0], last3DayStrs[1], last3DayStrs[2]]] forKeys:@[JSONMESSAGE_KEY_DATELIST]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsByDatesRequest messageBody:messageBody];
    
    [self requestAsync:SeedService
        requestMessage:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            callbackBlock(JSON, nil);
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            callbackBlock(JSON, nil);
        }];
}

-(void) seedsToCart:(NSString*) cartId seedIds:(NSArray*) seedIds callbackBlock:(JSONMessageCallBackBlock) callbackBlock;
{
    if (nil != seedIds && 0 < seedIds.count)
    {
        NSMutableDictionary* messageBody = [NSMutableDictionary dictionaryWithObject:seedIds forKey:JSONMESSAGE_KEY_SEEDIDLIST];
        [messageBody setValue:cartId forKey:JSONMESSAGE_KEY_CARTID];
        JSONMessage* message = [JSONMessage constructWithType:SeedsToCartRequest messageBody:messageBody];
        
        [self requestAsync:SeedService
            requestMessage:message
            success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
            {
                callbackBlock(JSON, nil);
            }
            failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
            {
                DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
                
                callbackBlock(JSON, error);
            }
        ];
    }
}

#pragma mark - Sync Invocations

-(JSONMessage*) alohaRequest
{
    JSONMessage* responseMessage = nil;
    
    NSDictionary* content = [NSDictionary dictionaryWithObjects:@[@"Hello Seeds Server!"] forKeys:@[JSONMESSAGE_KEY_CONTENT]];
    
    JSONMessage* requestMessage = [JSONMessage constructWithType:AlohaRequest messageBody:content];
    
    responseMessage = [self requestSync:SeedService requestMessage:requestMessage];
    
    return responseMessage;
}

-(JSONMessage*) seedsUpdateStatusByDatesRequest:(NSArray*) days
{
    JSONMessage* responseMessage = nil;
    
    NSMutableArray* dayStrs = [NSMutableArray array];
    if (nil != days)
    {
        for (NSDate* day in days)
        {
            NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
            [dayStrs addObject:dayStr];
        }
    }
    NSDictionary* dateListDic = [NSDictionary dictionaryWithObject:dayStrs forKey:JSONMESSAGE_KEY_DATELIST];

    JSONMessage* requestMessage = [JSONMessage constructWithType:SeedsUpdateStatusByDatesRequest messageBody:dateListDic];
    
    responseMessage = [self requestSync:SeedService requestMessage:requestMessage];
    
    return responseMessage;
}

-(JSONMessage*) seedsByDatesRequest:(NSArray*) days
{
    JSONMessage* responseMessage = nil;

    NSMutableArray* dayStrs = [NSMutableArray array];
    if (nil != days)
    {
        for (NSDate* day in days)
        {
            NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
            [dayStrs addObject:dayStr];
        }
    }
    NSDictionary* dateListDic = [NSDictionary dictionaryWithObject:dayStrs forKey:JSONMESSAGE_KEY_DATELIST];

    JSONMessage* requestMessage = [JSONMessage constructWithType:SeedsByDatesRequest messageBody:dateListDic];
    
    responseMessage = [self requestSync:SeedService requestMessage:requestMessage];
    
    return responseMessage;
}

-(JSONMessage*) seedsToCartRequest:(NSString*) cartId seedIds:(NSArray*) seedIds
{
    JSONMessage* responseMessage = nil;
    
    seedIds = (nil != seedIds) ? seedIds : @[];
    NSMutableDictionary* seedIdListDic = [NSMutableDictionary dictionaryWithObject:seedIds forKey:JSONMESSAGE_KEY_SEEDIDLIST];
    if (nil != cartId | 0 < cartId.length)
    {
        [seedIdListDic setObject:cartId forKey:JSONMESSAGE_KEY_CARTID];
    }
    JSONMessage* requestMessage = [JSONMessage constructWithType:SeedsToCartRequest messageBody:seedIdListDic];

    responseMessage = [self requestSync:CartService requestMessage:requestMessage];
    
    return responseMessage;
}

-(JSONMessage*) newCartIdRequest
{
    JSONMessage* responseMessage = [self seedsToCartRequest:nil seedIds:nil];    

    return responseMessage;
}

-(NSString*) newCartId
{
    NSString* cartId = nil;
    
    JSONMessage* responseMessage = [self seedsToCartRequest:nil seedIds:nil];
    if (nil != responseMessage)
    {
        if ([JSONMessage isTimeoutResponseMessage:responseMessage])
        {
            
        }
        else if ([JSONMessage isErrorResponseMessage:responseMessage])
        {
            
        }
        else
        {
            if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_SEEDSTOCARTRESPONSE])
            {
                NSDictionary* contentDic = responseMessage.body;
                NSDictionary* bodyDic = [contentDic objectForKey:JSONMESSAGE_KEY_BODY];
                cartId = [bodyDic objectForKey:JSONMESSAGE_KEY_CARTID];
            }
        }
    }
    
    return cartId;
}


#pragma mark - JSONMessageDelegate

-(void) requestAsync:(ServerServiceType) serverServiceType
      requestMessage:(JSONMessage*) requestMessage
    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableURLRequest* request = [ServerAgent constructURLRequest: requestMessage serverServiceType:serverServiceType];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];    
}

// Warning: This method CAN NOT be invoked in Main Thread!
-(JSONMessage*) requestSync:(ServerServiceType) serverServiceType requestMessage: (JSONMessage*) requestMessage
{
    if ([[NSThread currentThread] isMainThread])
    {
        DLog(@"Warning: This method CAN NOT be invoked in Main Thread!");
        return nil;
    }
    
    NSTimeInterval timeout = JSON_MESSAGE_TIMEOUT;
    NSDate* startTimeStamp = [NSDate date];
    NSDate* endTimeStamp = [NSDate dateWithTimeInterval:timeout sinceDate:startTimeStamp];
    
    __block JSONMessage* responseMessage = nil;

    __block NSCondition* lock = [[NSCondition alloc] init];
    
    id syncSuccessBlock = ^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
    {
        NSDictionary* content = (NSDictionary*)JSON;
        responseMessage = [JSONMessage constructWithContent:content];
        
        [lock lock];
        [lock signal];
        [lock unlock];
    };
    
    id syncFailureBlock = ^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
    {
        NSDictionary* content = (NSDictionary*)JSON;
        responseMessage = [JSONMessage constructWithContent:content];

        [lock lock];
        [lock signal];
        [lock unlock];
    };
    
    NSMutableURLRequest* request = [ServerAgent constructURLRequest:requestMessage serverServiceType:serverServiceType];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:syncSuccessBlock failure:syncFailureBlock];
    [operation start];
    
    [lock lock];
    BOOL flag = [lock waitUntilDate:endTimeStamp];
    [lock unlock];
    
    if (!flag)
    {
        [operation cancel];
        responseMessage = [JSONMessage constructWithType:TimeoutResponse messageBody:nil];
    }
    
    return responseMessage;
}

-(void) syncSeedsInfo
{
    // Step 10: 获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 向Server端发送AlohaRequest以检测通信状态，如果收到正确回复，则继续下一步，反之停止操作
    // Step 30: 向Server端发送SeedsUpdateStatusByDatesRequest，获取三个时间标对应的数据状态（a. 就绪；b. 未就绪；c. 无更新），更新相应的UI
    // Step 40: 向Server端发送SeedsByDatesRequest，获取Seed List，更新相应的UI
    // Step 50: 删除数据库中原有相同时间标的所有记录
    // Step 60: 再将新数据保存入数据库
    // Step 70: 删除数据库中处于这三天之前的所有记录
    // Step 80: 删除下载目录中原有的，处于这三天之前的的所有文件
    // Step 90: 删除缓存中所有已过期的图片
    
    [self _syncSeedsInfoWithSyncInvocations];
}

#pragma mark - Private Methods

-(void) _syncSeedsInfoWithSyncInvocations
{
    // Step 10
    NSArray* last3Days = [_userDefaults lastThreeDays];
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:last3Days formatString:STANDARD_DATE_FORMAT];
    NSArray* last3DayShortStrs = [CBDateUtils lastThreeDayStrings:last3Days formatString:SHORT_DATE_FORMAT];
    NSMutableArray* last3DaySyncStatuses = [NSMutableArray arrayWithCapacity:3];
    
    if (_delegate)
    {
        [_delegate showHUD];        
        [_delegate taskStarted:NSLocalizedString(@"Preparing", nil) minorStatus:nil];
        [_delegate taskIsProcessing:NSLocalizedString(@"Server Checking", nil) minorStatus:nil];        
    }
    
    @try
    {
        // Step 20
        JSONMessage* responseMessage = [self alohaRequest];
        if (nil != responseMessage)
        {
            if ([JSONMessage isTimeoutResponseMessage:responseMessage])
            {
                if (_delegate)
                {
                    [_delegate taskFailed:NSLocalizedString(@"Communication Timeout", nil) minorStatus:nil];
                }
            }
            else if ([JSONMessage isErrorResponseMessage:responseMessage])
            {
                if (_delegate)
                {
                    [_delegate taskFailed:NSLocalizedString(@"Error Responsed Message", nil) minorStatus:nil];
                }
            }
            else
            {
                if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_ALOHARESPONSE])
                {
                    NSDictionary* body = [responseMessage.body objectForKey:JSONMESSAGE_KEY_BODY];
                    // Step 30
                    if (_delegate)
                    {
                        [_delegate taskIsProcessing:NSLocalizedString(@"Server Reachable", nil) minorStatus:nil];
                        [_delegate taskIsProcessing:NSLocalizedString(@"Sync Status Checking", nil) minorStatus:nil];
                    }
                    
                    responseMessage = [self seedsUpdateStatusByDatesRequest:last3Days];
                    if (nil != responseMessage)
                    {
                        if ([JSONMessage isTimeoutResponseMessage:responseMessage])
                        {
                            if (_delegate)
                            {
                                [_delegate taskFailed:NSLocalizedString(@"Communication Timeout", nil) minorStatus:nil];
                            }
                        }
                        else if ([JSONMessage isErrorResponseMessage:responseMessage])
                        {
                            if (_delegate)
                            {
                                [_delegate taskFailed:NSLocalizedString(@"Error Responsed Message", nil) minorStatus:nil];
                            }
                        }
                        else
                        {
                            if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESRESPONSE])
                            {
                                body = [responseMessage.body objectForKey:JSONMESSAGE_KEY_BODY];
                                for (NSString* skey in last3DayStrs)
                                {
                                    NSString* sVal = [body objectForKey:skey];
                                    [last3DaySyncStatuses addObject:sVal];
                                }
                                
                                // Step 40
                                if (_delegate)
                                {
                                    [_delegate taskIsProcessing:NSLocalizedString(@"Sync Status Received", nil) minorStatus:nil];
                                    [_delegate taskIsProcessing:NSLocalizedString(@"Seeds Status Checking", nil) minorStatus:nil];
                                }
                                
                                responseMessage = [self seedsByDatesRequest:last3Days];
                                if (nil != responseMessage)
                                {
                                    if ([JSONMessage isTimeoutResponseMessage:responseMessage])
                                    {
                                        if (_delegate)
                                        {
                                            [_delegate taskFailed:NSLocalizedString(@"Communication Timeout", nil) minorStatus:nil];
                                        }
                                    }
                                    else if ([JSONMessage isErrorResponseMessage:responseMessage])
                                    {
                                        if (_delegate)
                                        {
                                            [_delegate taskFailed:NSLocalizedString(@"Error Responsed Message", nil) minorStatus:nil];
                                        }
                                    }
                                    else
                                    {
                                        if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_SEEDSBYDATESRESPONSE])
                                        {
                                            body = [responseMessage.body objectForKey:JSONMESSAGE_KEY_BODY];
                                            for (NSInteger index = 0; index < 3; index++)
                                            {
                                                NSDate* day = [last3Days objectAtIndex:index];
                                                NSString* dayStr = [last3DayStrs objectAtIndex:index];
                                                NSString* dayShortStr = [last3DayShortStrs objectAtIndex:index];
                                                
                                                NSMutableString* hudStr1 = [NSMutableString stringWithCapacity:0];
                                                [hudStr1 appendString:dayShortStr];
                                                [hudStr1 appendString:STR_SPACE];
                                                [hudStr1 appendString:NSLocalizedString(@"Pulling", nil)];
                                                
                                                BOOL isThisDaySync = [_userDefaults isThisDaySync:day];
                                                if (isThisDaySync)
                                                {
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskIsProcessing:hudStr1 minorStatus:NSLocalizedString(@"Pulled Yet", nil)];
                                                    }
                                                    continue;
                                                }
                                                
                                                NSString* syncStatus = [last3DaySyncStatuses objectAtIndex:index];
                                                if ([syncStatus isEqualToString:SEEDS_SYNCSTATUS_READY])
                                                {
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskIsProcessing:hudStr1 minorStatus:NSLocalizedString(@"Seeds Parsing", nil)];
                                                    }
                                                    
                                                    NSArray* seedDicsByDay = (NSArray*)[body objectForKey:dayStr];
                                                    NSArray* seedsByDay = [ServerAgent seedsFromDictionary:seedDicsByDay];
                                                    
                                                    // Step 50
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Organizing", nil)];
                                                    }
                                                    [_seedDAO deleteSeedsByDate:day];
                                                    
                                                    // Step 60
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Saving", nil)];
                                                    }
                                                    [_seedDAO insertSeeds:seedsByDay];
                                                    
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskDataUpdated:[NSString stringWithFormat:@"%d", index] data:[NSString stringWithFormat:@"%d", seedsByDay.count]];
                                                    }
                                                    
                                                    [_userDefaults setThisDaySync:day sync:YES];
                                                }
                                                else if ([syncStatus isEqualToString:SEEDS_SYNCSTATUS_NOUPDATE])
                                                {
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskDataUpdated:[NSString stringWithFormat:@"%d", index] data:[NSString stringWithFormat:@"%d", 0]];
                                                    }
                                                    
                                                    [_userDefaults setThisDaySync:day sync:YES];
                                                }
                                                else if ([syncStatus isEqualToString:SEEDS_SYNCSTATUS_NOTREADY])
                                                {
                                                    if (_delegate)
                                                    {
                                                        [_delegate taskDataUpdated:[NSString stringWithFormat:@"%d", index] data:NSLocalizedString(@"Not Ready", nil)];
                                                    }
                                                }
                                            }
                                            
                                            // Step 70
                                            if (_delegate)
                                            {
                                                [_delegate taskIsProcessing:NSLocalizedString(@"Seeds Organizing", nil) minorStatus:nil];
                                            }
                                            [_seedDAO deleteAllExceptLastThreeDaySeeds:last3Days];
                                            
                                            // Step 80
                                            [_downloadAgent clearDownloadDirectory:last3Days];
                                            
                                            // Step 90
                                            DLog(@"Clean all expired image cache in disk.");
                                            [_pictureAgent cleanExpiredCache];
                                            
                                            if (_delegate)
                                            {
                                                [_delegate taskFinished:NSLocalizedString(@"Completed", nil) minorStatus:nil];
                                            }
                                        }
                                        else
                                        {
                                            if (_delegate)
                                            {
                                                [_delegate taskFailed:NSLocalizedString(@"Unexpect Response Message", nil) minorStatus:nil];
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if (_delegate)
                                    {
                                        [_delegate taskFailed:NSLocalizedString(@"No Responsed Message", nil) minorStatus:nil];
                                    }
                                }
                            }
                            else
                            {
                                if (_delegate)
                                {
                                    [_delegate taskFailed:NSLocalizedString(@"Unexpect Response Message", nil) minorStatus:nil];
                                }
                            }
                        }
                    }
                    else
                    {
                        if (_delegate)
                        {
                            [_delegate taskFailed:NSLocalizedString(@"No Responsed Message", nil) minorStatus:nil];
                        }
                    }
                }
                else
                {
                    if (_delegate)
                    {
                        [_delegate taskFailed:NSLocalizedString(@"Unexpect Response Message", nil) minorStatus:nil];
                    }
                }
            }
        }
        else
        {
            if (_delegate)
            {
                [_delegate taskFailed:NSLocalizedString(@"No Responsed Message", nil) minorStatus:nil];
            }
        }
    }
    @catch(NSException* exception)
    {
        DLog(@"Caught an exception: %@", exception.debugDescription);
        
        if (_delegate)
        {
            [_delegate taskFailed:NSLocalizedString(@"Exception Caught", nil) minorStatus:nil];
        }
    }
    @finally
    {
    
    }
}

#pragma mark - Private Methods

@end
