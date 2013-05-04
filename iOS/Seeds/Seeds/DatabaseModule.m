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
    [NSThread sleepForTimeInterval:1.0];
    DLog(@"SQLite3 Database File Path: %@", self.databaseFilePath);
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    DLog(@"Seed count: %d",[seedDAO countAllSeeds]);
    
    NSArray* seeds = [seedDAO getAllSeeds];
    for (Seed* seed in seeds)
    {
        DLog(@"Seed {id=%d, name=%@, size=%@, torrentLink=%@, favorite=%@}", seed.seedId, seed.name, seed.size, seed.torrentLink, (seed.favorite) ? @"YES" : @"NO");
        
        DLog(@"Seed(%d) has been favorited: %@", seed.seedId, [seedDAO favoriteSeed:seed andFlag:YES] ? @"successfully." : @"unsuccessfully");
    }
}

-(NSString*) databaseFilePath
{
    if (nil == _databaseFilePath)
    {
        NSString* dbFileInXcodeProject = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_TYPE];
        DLog(@"Database File in Xcode Project: %@", dbFileInXcodeProject);

        NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
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
