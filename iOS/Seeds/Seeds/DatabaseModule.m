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

-(NSString*) sqlite3DatabaseFilePath;

@end

@implementation DatabaseModule

@synthesize databaseQueue = _databaseQueue;

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Database Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Database Module Thread", nil)];
    [self setKeepAlive:FALSE];
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.sqlite3DatabaseFilePath];
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
    DLog(@"SQLite3 Database File Path: %@", self.sqlite3DatabaseFilePath);
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    DLog(@"Seed count: %d",[seedDAO countAllSeeds]);
//    NSArray* seeds = [seedDAO getAllSeeds];
//    for (Seed* seed in seeds)
//    {
//        DLog(@"Seed {id=%d, name=%@, size=%@, torrentLink=%@}", seed.seedId, seed.name, seed.size, seed.torrentLink);
//    }
}

-(NSString*) sqlite3DatabaseFilePath
{
    NSString* databasePath = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_TYPE];
    return databasePath;
}

@end
