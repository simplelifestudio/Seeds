//
//  SeedDAOSQLiteImpl.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDAOFmdbImpl.h"

@interface SeedDAOFmdbImpl()
{
    __weak FMDatabaseQueue* databaseQueue;
}
@end

@implementation SeedDAOFmdbImpl

-(void) attachDatabaseHandler:(id) handler
{
    if (nil != handler && [handler isKindOfClass:[FMDatabaseQueue class]])
    {
        databaseQueue = handler;
    }
}

-(NSArray*) resultSet2SeedList:(FMResultSet*) rs
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != rs)
    {
        while ([rs next])
        {
            Seed* seed = [[Seed alloc] init];
            
            seed.seedId = [rs intForColumn:TABLE_SEED_COLUMN_SEEDID];
            seed.type = [rs stringForColumn:TABLE_SEED_COLUMN_TYPE];
            seed.publishDate = [rs stringForColumn:TABLE_SEED_COLUMN_PUBLISHDATE];
            seed.name = [rs stringForColumn:TABLE_SEED_COLUMN_NAME];
            seed.size = [rs stringForColumn:TABLE_SEED_COLUMN_SIZE];
            seed.format = [rs stringForColumn:TABLE_SEED_COLUMN_FORMAT];
            seed.torrentLink = [rs stringForColumn:TABLE_SEED_COLUMN_TORRENTLINK];
            seed.favorite = [rs boolForColumn:TABLE_SEED_COLUMN_FAVORITE];
            seed.mosaic = [rs boolForColumn:TABLE_SEED_COLUMN_MOSAIC];
            seed.hash = [rs stringForColumn:TABLE_SEED_COLUMN_HASH];
            seed.memo = [rs stringForColumn:TABLE_SEED_COLUMN_MEMO];
            
            [array addObject:seed];
        }
    }
    
    return array;
}

-(Seed*) resultSet2Seed:(FMResultSet*) rs
{
    Seed* seed;
    
    NSArray* seedList = [self resultSet2SeedList:rs];
    if (0 < seedList.count)
    {
        seed = [seedList objectAtIndex:0];
    }
    
    return seed;
}

-(NSInteger) countAllSeeds
{
    __block NSInteger count = 0;

    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select count("];
        [sql appendString:TABLE_SEED_COLUMN_SEEDID];
        [sql appendString:@") from "];
        [sql appendString:TABLE_SEED];
        
        count = [db intForQuery:sql];
        
        [db close];
    }];
    
    return count;
}

-(NSArray*) getAllSeeds
{
    __block NSArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
        [sql appendString:TABLE_SEED];
        
        FMResultSet* resultSet = [db executeQuery:sql];
        array = [self resultSet2SeedList:resultSet];

        [resultSet close];
        [db close];
    }];
    
    return array;
}

-(BOOL) updateSeed:(NSInteger) seedId withParameterDictionary:(NSMutableDictionary*) paramDic
{
    __block BOOL flag = NO;
    
    if (nil != paramDic && 0 < paramDic.count)
    {
        [databaseQueue inDatabase:^(FMDatabase* db)
         {
             [db open];
             
             __block NSMutableString* sql = [NSMutableString stringWithString:@"update "];
             [sql appendString:TABLE_SEED];
             [sql appendString:@" set "];
             
             __block NSInteger paramCount = paramDic.count;
             [paramDic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop)
             {
                 [sql appendString:key];
                 [sql appendString:@" = "];
//                 [sql appendString:@"'"];
                 [sql appendString:@":"];
                 [sql appendString:key];
//                 [sql appendString:@"'"];
                 if (1 < paramCount)
                 {
                     [sql appendString:@", "];
                 }
                 
                 paramCount--;
             }];
             
             [sql appendString:@" WHERE "];
             [sql appendString:TABLE_SEED_COLUMN_SEEDID];
             [sql appendString:@" = "];
             [sql appendString:@"'"];
             [sql appendString:[NSString stringWithFormat: @"%d", seedId]];
             [sql appendString:@"'"];
             
             DLog(@"sql = %@", sql);
             flag = [db executeUpdate:sql withParameterDictionary:paramDic];
             
             [db close];
         }];
    }
    
    return flag;
}

-(NSArray*) getFavoriteSeeds
{
    __block NSArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
        [sql appendString:TABLE_SEED];
        [sql appendString:@" where favorite = '1'"];

        FMResultSet* resultSet = [db executeQuery:sql];
        array = [self resultSet2SeedList:resultSet];
        
        [resultSet close];
        [db close];
    }];
    
    return array;
}

-(BOOL) favoriteSeed:(Seed*) seed andFlag:(BOOL) favorite
{
    BOOL flag = NO;
    
    if (nil != seed)
    {
        NSString* favoriteStr = [NSString stringWithFormat:@"%d", (favorite) ? 1 : 0];
        
        NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setObject:favoriteStr forKey:TABLE_SEED_COLUMN_FAVORITE];
        
        flag = [self updateSeed:seed.seedId withParameterDictionary:paramDic];
    }
    
    return flag;
}

-(BOOL) deleteSeedsByDate:(NSString*) dateStr
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        if (nil != dateStr)
        {
            NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
            [sql appendString:TABLE_SEED];
            [sql appendString:@" where "];
            [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
            [sql appendString:@" = "];
            [sql appendString:dateStr];
            
            flag = [db executeUpdate:sql];
        }
        
        [db close];
    }];
    
    return flag;
}

-(BOOL) deleteAllSeeds
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
        [sql appendString:TABLE_SEED];
        
        flag = [db executeUpdate:sql];

        [db close];
    }];
    
    return flag;
}

-(BOOL) insertSeed:(Seed *)seed
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        if (nil != seed)
        {
            NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
            [sql appendString:TABLE_SEED];
            [sql appendString:@" ("];
//            [sql appendString:TABLE_SEED_COLUMN_SEEDID];
//            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_TYPE];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_NAME];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_SIZE];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_FORMAT];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_TORRENTLINK];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_FAVORITE];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_MOSAIC];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_HASH];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_MEMO];
            [sql appendString:@") values ("];
            [sql appendString:@"?, ?, ?, ?, ?, ?, ?, ?, ?, ?"];
            [sql appendString:@")"];
            
            BOOL hadError = [db hadError];
            
            flag = [db executeUpdate:sql, seed.type, seed.publishDate, seed.name, seed.size, seed.format, seed.torrentLink, (seed.favorite) ? @"1" : @"0", (seed.mosaic) ? @"1" : @"0", seed.hash, seed.memo];
            hadError = [db hadError];
            if (hadError)
            {
                NSLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            if (!flag)
            {
                DLog(@"Fail to insert seed record with name: %@", seed.name);
            }
        }
        
        [db close];
    }];
    
//    [databaseQueue inTransaction:^(FMDatabase* db, BOOL* rollback)
//    {
//        BOOL optSuccess = [db open];
//        
//        if (nil != seed)
//        {
//            NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
//            [sql appendString:TABLE_SEED];
//            [sql appendString:@" ("];
//            [sql appendString:TABLE_SEED_COLUMN_SEEDID];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_TYPE];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_NAME];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_SIZE];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_FORMAT];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_TORRENTLINK];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_FAVORITE];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_MOSAIC];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_HASH];
//            [sql appendString:@", "];
//            [sql appendString:TABLE_SEED_COLUMN_MEMO];
//            [sql appendString:@") values ("];
//            [sql appendString:@"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"];
//            [sql appendString:@")"];
//            
//            flag = [db executeUpdate:sql, seed.seedId, seed.type, seed.publishDate, seed.name, seed.size, seed.format, seed.torrentLink, seed.favorite, seed.mosaic, seed.hash, seed.memo];
//            if (flag)
//            {
//                DLog(@"Seed table has %d records after insert operation.", [self countAllSeeds]);
//            }
//            else
//            {
//                DLog(@"Fail to insert seed record with name: %@", seed.name);
//            }
//        }
//        
//        [db close];
//    }];
    
    return flag;
}

-(BOOL) insertSeeds:(NSArray*) seeds
{
    BOOL flag = NO;
    
    for (Seed* seed in seeds)
    {
        [self insertSeed:seed];
    }
    
    return flag;
}

@end
