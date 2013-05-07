//
//  JSONMessageDelegate.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONMessageDelegate

//-(void) requestAsync:(NSURL*) url requestMessage:(JSONMessage*) requestMessage responseSelector:(SEL) selector;
-(void) requestAsync:
            (NSURL*) url
            requestMessage:(JSONMessage*) requestMessage
            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end