//
//  DatabaseModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"

#import <sqlite3.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

enum ServiceDay {TheDayBefore = 0, Yesterday = 1, Today = 2};

@interface DatabaseModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@property (atomic, strong) FMDatabaseQueue *databaseQueue;

@end
