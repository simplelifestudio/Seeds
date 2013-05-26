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
    
}

@end

@implementation ServerAgent

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

-(void) alohaTest
{
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@"Hello XX Chris Server!"] forKeys:@[@"content"]];
    JSONMessage* message = [JSONMessage constructWithType:AlohaRequest paramList:messageBody];
    DLog(@"Request message:%@",message.body);
    [self requestAsync:
     message
               success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
     {
         NSDictionary* messageContent = (NSDictionary*)JSON;
         JSONMessage* responseMessage = [JSONMessage constructWithContent:messageContent];
         // Deal with response json message
         DLog(@"Success to receive json message:%@ with response: %@", responseMessage.command, responseMessage.body);
     }
               failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
     {
         DLog(@"Failed to receive json message with error code: %d", error.code);
     }
     ];
}

-(void) updateStatusByDatesTest
{
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[@"2013-05-23", @"2013-05-24", @"2013-05-25"]] forKeys:@[@"datelist"]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsUpdateStatusByDatesRequest paramList:messageBody];

    DLog(@"Request message:%@", message.body);
    [self requestAsync:
            message
            success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
            {
                NSDictionary* messageContent = (NSDictionary*)JSON;
                JSONMessage* responseMessage = [JSONMessage constructWithContent:messageContent];
                // Deal with response json message
                DLog(@"Success to receive json message:%@ with response: %@", responseMessage.command, responseMessage.body);
            }
            failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
            {
                DLog(@"Failed to receive json message with error code: %@", error.localizedDescription);
            }
    ];
}

-(void) seedsByDatesTest
{
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@[@"2013-05-23", @"2013-05-24", @"2013-05-25"]] forKeys:@[@"datelist"]];
    JSONMessage* message = [JSONMessage constructWithType:SeedsByDatesRequest paramList:messageBody];
    
    [self requestAsync:
     message
               success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
     {
         NSDictionary* messageContent = (NSDictionary*)JSON;
         JSONMessage* responseMessage = [JSONMessage constructWithContent:messageContent];
         // Deal with response json message
         DLog(@"Success to receive json message:%@ with response: %@", responseMessage.command, responseMessage.body);
     }
               failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON)
     {
         DLog(@"Failed to receive json message with error code: %d", error.code);
     }
     ];
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

@end
