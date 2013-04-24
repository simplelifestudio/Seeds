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
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    SeedDAOFmdbImpl* seedDAO = [[SeedDAOFmdbImpl alloc] init];
    [seedDAO attachDatabaseHandler:appDelegate.databaseModule.databaseQueue];
    return seedDAO;
}

+(id<SeedPictureDAO>) getSeedPictureDAO
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    SeedPictureDAOFmdbImpl* seedPictureDAO = [[SeedPictureDAOFmdbImpl alloc] init];
    [seedPictureDAO attachDatabaseHandler:appDelegate.databaseModule.databaseQueue];
    return seedPictureDAO;
}

@end
