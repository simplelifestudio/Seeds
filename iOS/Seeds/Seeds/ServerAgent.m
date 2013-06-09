//
//  ServerAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "ServerAgent.h"

@interface ServerAgent()
{
    NSArray* _last3Days;
    JSONMessage* _responseMessage;
}

@end

@implementation ServerAgent

@synthesize delegate = _delegate;

+(NSMutableURLRequest*) constructURLRequest:(JSONMessage*) message
{
    NSAssert(nil != message, @"Nil JSON Message");
    
    NSMutableURLRequest* request = nil;
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASEURL_SEEDSSERVER]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    request = [httpClient
               requestWithMethod:@"POST"
               path:PATH_MESSAGELISTENER
               parameters:message.body];
    
    return request;
}

-(id) init
{
    self = [super init];
    
    if (nil != self)
    {
        
    }
    
    return self;
}

-(void) aloha
{
    _last3Days = [CBDateUtils lastThreeDays];

    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@"Hello Seeds Server!"] forKeys:@[@"content"]];
    JSONMessage* message = [JSONMessage constructWithType:AlohaRequest paramList:messageBody];
    DLog(@"Request message:%@",message.body);
    [self requestAsync:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];
            DLog(@"Success to receive json message:%@ with response: %@", _responseMessage.command, _responseMessage.body);
         
            if (nil != _delegate)
            {
                [_delegate taskIsProcessing:NSLocalizedString(@"Server Reachable", nil) minorStatus:nil];                
                [self seedsUpdateStatusByDates:_last3Days];
            }
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];
            
            if (nil != _delegate)
            {
                [_delegate taskFailed:NSLocalizedString(@"Server Unreachable", nil) minorStatus:nil];
            }
        }
     ];
}

-(void) seedsUpdateStatusByDates:(NSArray*) dates
{
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:dates formatString:STANDARD_DATE_FORMAT];
    
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[last3DayStrs[0], last3DayStrs[1], last3DayStrs[2]]] forKeys:@[JSONMESSAGE_KEY_DATELIST]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsUpdateStatusByDatesRequest paramList:messageBody];

    DLog(@"Request message:%@", message.body);
    [self requestAsync:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];

            DLog(@"Success to receive json message:%@ with response: %@", _responseMessage.command, _responseMessage.body);
                
            if (nil != _delegate)
            {
                [_delegate taskIsProcessing:NSLocalizedString(@"Seeds Status Received", nil) minorStatus:nil];
                [self seedsByDates:_last3Days];
            }
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];
                
            if (nil != _delegate)
            {
                [_delegate taskFailed:NSLocalizedString(@"Seeds Status Unreachable", nil) minorStatus:nil];                
            }
        }];
}

-(void) seedsByDates:(NSArray*) dates
{
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:dates formatString:STANDARD_DATE_FORMAT];
    
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[last3DayStrs[0], last3DayStrs[1], last3DayStrs[2]]] forKeys:@[JSONMESSAGE_KEY_DATELIST]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsByDatesRequest paramList:messageBody];
    
    [self requestAsync:message
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
        {
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];

            DLog(@"Success to receive json message:%@ with response: %@", _responseMessage.command, _responseMessage.body);
            
            if (nil != _delegate)
            {
                [_delegate taskIsProcessing:@"Seeds Received" minorStatus:nil];
                // TODO:
            }
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
        {
            DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            
            NSDictionary* messageContent = (NSDictionary*)JSON;
            _responseMessage = [JSONMessage constructWithContent:messageContent];
            
            if (nil != _delegate)
            {
                [_delegate taskFailed:@"Seeds Unreachable" minorStatus:nil];
            }
        }];
}

-(void) requestAsync:
        (JSONMessage*) requestMessage
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableURLRequest* request = [ServerAgent constructURLRequest:requestMessage];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];    
}

-(void) syncSeedsInfo
{
    // Step 10: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 在本地KV缓存中，检查时间标对应的数据同步状态：（a. 已同步；b. 未同步），如果是未同步状态，则继续下一步，反之停止操作
    // Step 30: 向Server端发送SeedsUpdateStatusByDatesRequest，获取三个时间标对应的数据状态（a. 就绪；b. 未就绪；c. 无更新），更新相应的UI
    // Step 40: 向Server端发送SeedsByDatesRequest，获取Seed List，更新相应的UI
    // Step 50: 删除数据库中原有相同时间标的所有记录
    // Step 60: 再将新数据保存入数据库（事务操作）
    // Step 70: 更新本地KV缓存中时间标的对应数据同步状态
    // Step 80: 删除数据库中原有的，处于这三天之前的，非收藏状态的所有记录
    
    if (_delegate)
    {
        [_delegate taskStarted:NSLocalizedString(@"Preparing", nil) minorStatus:nil];
    }
    
    [self aloha];
}

@end
