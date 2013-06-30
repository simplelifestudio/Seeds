//
//  JSONMessage.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "JSONMessage.h"

@implementation JSONMessage

@synthesize command = _command;
@synthesize body = _body;

+(JSONMessage*) construct:(NSString*) command messageBody:(NSDictionary*) body
{
    JSONMessage* message = nil;
    
    if (nil != command && 0 < command.length)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setObject:command forKey:JSONMESSAGE_KEY_COMMAND];
        if (nil != body)
        {
            [dic setObject:body forKey:JSONMESSAGE_KEY_PARAMLIST];
        }
        message = [[JSONMessage alloc] init];
        [message setCommand:command];
        [message setBody:dic];
    }
    
    return message;
}

+(JSONMessage*) constructWithType:(JSONMessageType) type messageBody:(NSDictionary*) body
{
    JSONMessage* message = nil;
    NSString* command = nil;
    switch (type)
    {
        case AlohaRequest:
        {
            command = JSONMESSAGE_COMMAND_ALOHAREQUEST;
            break;
        }
        case AlohaResponse:
        {
            command = JSONMESSAGE_COMMAND_ALOHARESPONSE;
            break;
        }
        case SeedsUpdateStatusByDatesRequest:
        {
            command = JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESREQUEST;
            break;
        }
        case SeedsUpdateStatusByDatesResponse:
        {
            command = JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESRESPONSE;
            break;
        }
        case SeedsByDatesRequest:
        {
            command = JSONMESSAGE_COMMAND_SEEDSBYDATESREQUEST;
            break;
        }
        case SeedsByDatesResponse:
        {
            command = JSONMESSAGE_COMMAND_SEEDSBYDATESRESPONSE;
            break;
        }
        case SeedsToCartRequest:
        {
            command = JSONMESSAGE_COMMAND_SEEDSTOCARTREQUEST;
            break;
        }
        case SeedsToCartResponse:
        {
            command = JSONMESSAGE_COMMAND_SEEDSTOCARTRESPONSE;
            break;
        }
        case ExternalSeedsToCartRequest:
        {
            command = JSONMESSAGE_COMMAND_EXTERNALSEEDSTOCARTREQUEST;
            break;
        }
        case ExternalSeedsToCartResponse:
        {
            command = JSONMESSAGE_COMMAND_EXTERNALSEEDSTOCARTRESPONSE;
            break;
        }
        default:
        {
            break;
        }
    }
    
    if (nil != command)
    {
        body = (nil != body) ? body : [NSDictionary dictionary];
        
        message = [JSONMessage construct:command messageBody:body];
    }
    
    return message;
}

+(JSONMessage*) constructWithContent:(NSDictionary*) content
{
    JSONMessage* message = nil;
    
    if (nil != content)
    {
        NSString* command = [content objectForKey:JSONMESSAGE_KEY_COMMAND];
        NSDictionary* body = [content objectForKey:JSONMESSAGE_KEY_PARAMLIST];

        message = [JSONMessage construct:command messageBody:body];
    }
    
    return message;
}

-(NSDictionary*) content
{
    NSDictionary* content = [_body objectForKey:JSONMESSAGE_KEY_PARAMLIST];
    
    return content;
}

@end
