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
        
//        DLog(@"Seed(%d) has been favorited: %@", seed.seedId, [seedDAO favoriteSeed:seed andFlag:YES] ? @"successfully." : @"unsuccessfully");
    }
}

-(NSString*) databaseFilePath
{
    if (nil == _databaseFilePath)
    {
        //databaseFilePath = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_TYPE];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];        
        _databaseFilePath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_FULL_NAME];
    }
    
    return _databaseFilePath;
}

@end
