//
//  TransmitModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBNetworkUtils.h"

#define HTTP_SERVER_NAME @"Seeds Http Server"

@interface TransmissionModule : CBModuleAbstractImpl <CBSharedInstance>

-(void) startHTTPServer;
-(void) stopHTTPServer;

-(NSInteger) httpServerPort;
-(NSString*) httpServerName;

@end
