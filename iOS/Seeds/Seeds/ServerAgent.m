//
//  ServerAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "ServerAgent.h"

#define BASEURL_SEEDSSERVER @"http://106.187.36.105"
#define PATH_MESSAGELISTENER @"/seeds/messageListener"

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
    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@"Seeds for iPhone", @"Patrick Deng", @"SimpleLife Studio"] forKeys:@[@"client", @"author", @"organization"]];
    JSONMessage* alohaMessage = [JSONMessage constructWithType:AlohaRequest paramList:messageBody];
    
    [self requestAsync:
            alohaMessage
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

@end
