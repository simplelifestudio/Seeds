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
    SeedsByDatesResponse,
    SeedsToCartRequest,
    SeedsToCartResponse,
    ExternalSeedsToCartRequest,
    ExternalSeedsToCartResponse
}
JSONMessageType;

@interface JSONMessage : NSObject

@property (nonatomic, strong) NSString* command;
@property (nonatomic, strong) NSDictionary* body;

+(JSONMessage*) construct:(NSString*) command messageBody:(NSDictionary*) body;
+(JSONMessage*) constructWithType:(JSONMessageType) type messageBody:(NSDictionary*) body;
+(JSONMessage*) constructWithContent:(NSDictionary*) content;

-(NSDictionary*) content;

@end
