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

-(void) alohaTest
{
    NSURL *url = [NSURL URLWithString:@"http://server_ip/messagelistener"];

    NSDictionary* messageBody = [NSDictionary dictionaryWithObjects:@[@"Seeds for iPhone", @"Patrick Deng", @"SimpleLife Studio"] forKeys:@[@"client", @"author", @"organization"]];
    JSONMessage* alohaMessage = [JSONMessage constructWithType:AlohaRequest paramList:messageBody];
    
    [self requestAsync:
            url requestMessage:alohaMessage
            success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
            {
//                NSDictionary* message = (NSDictionary*)JSON;
                
                NSError* error = [[NSError alloc] init];
                NSDictionary* messageContent = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableLeaves error:&error];
                
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
        (NSURL*) url
        requestMessage:(JSONMessage*) requestMessage
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

@end
