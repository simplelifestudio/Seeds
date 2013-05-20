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
#define HTTP_SERVER_PORT 8964

#define FILE_EXTENDNAME_DOT_ZIP @".zip"

@interface TransmissionModule : CBModuleAbstractImpl <CBSharedInstance>

-(BOOL) startHTTPServer;
-(void) stopHTTPServer;

-(NSInteger) httpServerPort;
-(NSString*) httpServerName;

-(BOOL) generateHtmlPage:(NSArray*) last3Days;

@end
