//
//  JSONMessage.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSONMESSAGE_KEY_COMMAND @"command"
#define JSONMESSAGE_KEY_PARAMLIST @"paramList"

#define JSONMESSAGE_COMMAND_ALOHAREQUEST @"AlohaRequet"
#define JSONMESSAGE_COMMAND_ALOHARESPONSE @"AlohaResponse"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESREQUEST @"SeedsUpdateStatusByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESRESPONSE @"SeedsUpdateStatusByDatesResponse"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESREQUEST @"SeedsByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESRESPONSE @"SeedsByDatesResponse"

typedef enum 
{
    AlohaRequest,
    AlohaResponse,
    SeedsUpdateStatusByDatesRequest,
    SeedsUpdateStatusByDatesResponse,
    SeedsByDatesRequest,
    SeedsByDatesResponse
}
JSONMessageType;

@interface JSONMessage : NSObject

@property (nonatomic, strong) NSString* command;
@property (nonatomic, strong) NSDictionary* body;

+(JSONMessage*) construct:(NSString*) command paramList:(NSDictionary*) paramList;
+(JSONMessage*) constructWithType:(JSONMessageType) type paramList:(NSDictionary*) paramList;
+(JSONMessage*) constructWithContent:(NSDictionary*) content;

@end
