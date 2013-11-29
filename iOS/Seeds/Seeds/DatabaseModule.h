//
//  DatabaseModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"

#import <sqlite3.h>

#import "fmdb/FMDatabase.h"
#import "fmdb/FMDatabaseAdditions.h"
#import "fmdb/FMDatabasePool.h"
#import "fmdb/FMDatabaseQueue.h"
#import "fmdb/FMResultSet.h"

@interface DatabaseModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@property (atomic, strong) FMDatabaseQueue *databaseQueue;

@end
