//
//  ServerAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-4.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "JSONMessage.h"
#import "JSONMessageDelegate.h"

@interface ServerAgent : NSObject <JSONMessageDelegate>

-(void) alohaTest;

@end