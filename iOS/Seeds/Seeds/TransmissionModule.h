//
//  TransmitModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"

@interface TransmissionModule : CBModuleAbstractImpl

-(void) startHTTPServer;
-(NSInteger) httpServerPort;
-(void) stopHTTPServer;

@end
