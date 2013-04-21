//
//  CBModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CBModule <NSObject>

@property BOOL isIndividualThreadNecessary;
@property BOOL keepAlive;

@property (nonatomic, strong) NSString *moduleIdentity;
@property (nonatomic, strong) NSThread *serviceThread;

-(void) initModule;
-(void) startService;
-(void) processService;
-(void) pauseService;
-(void) serviceWithIndividualThread;
-(void) serviceWithCallingThread;
-(void) stopService;
-(void) releaseModule;

@end