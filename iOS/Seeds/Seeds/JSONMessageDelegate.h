//
//  JSONMessageDelegate.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {SeedService = 0, CartService} ServerServiceType;

@protocol JSONMessageDelegate

-(void) requestAsync:(ServerServiceType) serverServiceType
    requestMessage: (JSONMessage*) requestMessage
    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

// Warning: This method CAN NOT be invoked in Main Thread!
-(JSONMessage*) requestSync:(ServerServiceType) serverServiceType requestMessage:(JSONMessage*) requestMessage;

@end