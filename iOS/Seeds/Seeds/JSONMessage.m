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
        [dic setObject:command forKey:JSONMESSAGE_KEY_ID];
        if (nil != body)
        {
            [dic setObject:body forKey:JSONMESSAGE_KEY_BODY];
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
        case ErrorResponse:
        {
            command = JSONMESSAGE_COMMAND_ERRORRESPONSE;
            break;
        }
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
        NSString* command = [content objectForKey:JSONMESSAGE_KEY_ID];
        NSDictionary* body = [content objectForKey:JSONMESSAGE_KEY_BODY];

        message = [JSONMessage construct:command messageBody:body];
    }
    
    return message;
}

+(JSONMessageErrorCode) verify:(JSONMessage*) message
{
    JSONMessageErrorCode error = LegalResponseMessage;
    
    if (nil != message)
    {
        NSString* messageId = message.command;
        if (nil != messageId && 0 < messageId.length)
        {
            if ([messageId isEqualToString:JSONMESSAGE_COMMAND_ERRORRESPONSE])
            {
                error = ErrorResponseMessage;
            }
        }
        else
        {
            error = IllegalResponseMessage;
        }
    }
    else
    {
        error = NoResponseMessage;
    }
    
    return error;
}

+(BOOL) isErrorResponseMessage:(JSONMessage*) message
{
    BOOL flag = NO;
    
    if (nil != message && [message.command isEqualToString:JSONMESSAGE_COMMAND_ERRORRESPONSE])
    {
        flag = YES;
    }
    
    return flag;
}

-(NSDictionary*) content
{
    NSDictionary* content = [NSDictionary dictionaryWithObjects:@[_command, _body] forKeys:@[JSONMESSAGE_KEY_ID, JSONMESSAGE_KEY_BODY]];
    
    return content;
}

@end
