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

+(JSONMessage*) construct:(NSString*) command paramList:(NSDictionary*) paramList
{
    JSONMessage* message = nil;
    
    if (nil != command && 0 < command.length)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setObject:command forKey:JSONMESSAGE_KEY_COMMAND];
        if (nil != paramList)
        {
            [dic setObject:paramList forKey:JSONMESSAGE_KEY_PARAMLIST];
        }
        
        message = [[JSONMessage alloc] init];
        [message setCommand:command];
        [message setBody:dic];
    }
    
    return message;
}

+(JSONMessage*) constructWithType:(JSONMessageType) type paramList:(NSDictionary*) paramList
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
        default:
        {
            break;
        }
    }
    
    if (nil != command)
    {
        message = [JSONMessage construct:command paramList:paramList];
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

        message = [JSONMessage construct:command paramList:body];
    }
    
    return message;
}

@end
