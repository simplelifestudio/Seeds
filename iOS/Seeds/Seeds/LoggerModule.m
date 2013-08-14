//
//  LoggerModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "LoggerModule.h"

@implementation LoggerModule

SINGLETON(UserDefaultsModule)

@synthesize fileLogger = _fileLogger;

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Logger Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Logger Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

-(void) releaseModule
{
    [super releaseModule];
}

-(void) startService
{
    DDLogVerbose(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    MODULE_DELAY
}

-(DDFileLogger*) fileLogger
{
    if (nil == _fileLogger)
    {
        _fileLogger = [[DDFileLogger alloc] init];
        _fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        
        [DDLog addLogger:_fileLogger];
    }
    
    return _fileLogger;
}

@end
