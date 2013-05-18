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

+(id)sharedInstance
{
    static DatabaseModule* sharedInstance;
    static dispatch_once_t done;
    dispatch_once
    (
     &done,
     ^
     {
         sharedInstance = [[DatabaseModule alloc] initWithIsIndividualThreadNecessary:NO];
     }
     );
    return sharedInstance;
}

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
    [NSThread sleepForTimeInterval:0.5];
    DLog(@"SQLite3 Database File Path: %@", self.databaseFilePath);
}

-(NSString*) databaseFilePath
{
    if (nil == _databaseFilePath)
    {
        NSString* dbFileInXcodeProject = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_TYPE];
        DLog(@"Database File in Xcode Project: %@", dbFileInXcodeProject);

        NSString *documentsDir = [CBPathUtils documentsDirectoryPath];
        
        _databaseFilePath = [documentsDir stringByAppendingPathComponent:DATABASE_FILE_FULL_NAME];
        DLog(@"Database File in App Sandbox: %@", _databaseFilePath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
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
            optCode = [fileManager copyItemAtPath:dbFileInXcodeProject toPath:_databaseFilePath error:&error];
            DLog(@"Database File in App Sandbox copied: %@", (optCode) ? @"YES" : @"NO");
        }
    }
    
    return _databaseFilePath;
}

@end
