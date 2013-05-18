//
//  DAOFactory.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "DAOFactory.h"

@implementation DAOFactory

+(id<SeedDAO>) getSeedDAO
{
    DatabaseModule* databaseModule = [DatabaseModule sharedInstance];
    SeedDAOFmdbImpl* seedDAO = [[SeedDAOFmdbImpl alloc] init];
    [seedDAO attachDatabaseHandler:databaseModule.databaseQueue];
    return seedDAO;
}

+(id<SeedPictureDAO>) getSeedPictureDAO
{
    DatabaseModule* databaseModule = [DatabaseModule sharedInstance];
    SeedPictureDAOFmdbImpl* seedPictureDAO = [[SeedPictureDAOFmdbImpl alloc] init];
    [seedPictureDAO attachDatabaseHandler:databaseModule.databaseQueue];
    return seedPictureDAO;
}

@end
