//
//  DatabaseModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "DatabaseModule.h"

#import "DAOFactory.h"

@interface DatabaseModule()
{

}

@property (nonatomic, strong) NSString* databaseFilePath;

@end

@implementation DatabaseModule

@synthesize databaseFilePath = _databaseFilePath;
@synthesize databaseQueue = _databaseQueue;

SINGLETON(DatabaseModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Database Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Database Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.databaseFilePath];
}

-(void) releaseModule
{
    [_databaseQueue close];
    [super releaseModule];
}

-(void) startService
{
    DLog(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    DLog(@"SQLite3 Database File Path: %@", self.databaseFilePath);
    
    MODULE_DELAY   
}

-(NSString*) databaseFilePath
{
    if (nil == _databaseFilePath)
    {
        _databaseFilePath = [Environment databaseFilePath];
        
        NSString* _databaseFilePathInXcodeProject = [Environment databaseFilePathInXcodeProject];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        BOOL optCode = [fileManager fileExistsAtPath:_databaseFilePath];
        DLog(@"Database File in App Sandbox exists: %@", (optCode) ? @"YES" : @"NO");
        
        NSError* error = nil;
        BOOL needCopy = NO;
        if (optCode)
        {
            NSDictionary *attr = [fileManager attributesOfItemAtPath:_databaseFilePath error:&error];
            int fileSize = [[attr objectForKey: NSFileSize] intValue];
            if(0 >= fileSize)
            {
                needCopy = YES;
            }
        }
        else
        {
            needCopy = YES;
        }

        if (needCopy)
        {
            DLog(@"Database File need re-copy: %@", (needCopy) ? @"YES" : @"NO");
            optCode = [fileManager removeItemAtPath:_databaseFilePath error:nil];
            DLog(@"Database File in App Sandbox removed: %@", (optCode) ? @"YES" : @"NO");
            NSString* _databaseFileDirPath = [_databaseFilePath stringByDeletingLastPathComponent];
            BOOL b = YES;
            optCode = [fileManager fileExistsAtPath:_databaseFileDirPath isDirectory:&b];
            if (!optCode)
            {
                [fileManager createDirectoryAtPath:_databaseFileDirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            optCode = [fileManager copyItemAtPath:_databaseFilePathInXcodeProject toPath:_databaseFilePath error:&error];
            DLog(@"Database File in App Sandbox copied: %@", (optCode) ? @"YES" : @"NO");
        }
    }
    
    return _databaseFilePath;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

@end
