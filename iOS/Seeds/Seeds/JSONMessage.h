//
//  JSONMessage.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

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

-(NSDictionary*) content;

@end
