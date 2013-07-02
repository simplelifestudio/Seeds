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

-(NSArray*) resultSet2SeedList:(FMResultSet*) rs databaseHandler:(FMDatabase*) db;
-(Seed*) resultSet2Seed:(FMResultSet*) rs databaseHandler:(FMDatabase*) db;

@end

@implementation SeedDAOFmdbImpl

-(void) attachDatabaseHandler:(id) handler
{
    if (nil != handler && [handler isKindOfClass:[FMDatabaseQueue class]])
    {
        databaseQueue = handler;
    }
}

-(NSArray*) resultSet2SeedList:(FMResultSet*) rs databaseHandler:(FMDatabase *)db
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != rs)
    {
        while ([rs next])
        {
            Seed* seed = [[Seed alloc] init];
            
            seed.localId = [rs intForColumn:TABLE_SEED_COLUMN_LOCALID];
            seed.seedId = [rs intForColumn:TABLE_SEED_COLUMN_SEEDID];
            seed.type = [rs stringForColumn:TABLE_SEED_COLUMN_TYPE];
            seed.source = [rs stringForColumn:TABLE_SEED_COLUMN_SOURCE];
            seed.publishDate = [rs stringForColumn:TABLE_SEED_COLUMN_PUBLISHDATE];
            seed.name = [rs stringForColumn:TABLE_SEED_COLUMN_NAME];
            seed.size = [rs stringForColumn:TABLE_SEED_COLUMN_SIZE];
            seed.format = [rs stringForColumn:TABLE_SEED_COLUMN_FORMAT];
            seed.torrentLink = [rs stringForColumn:TABLE_SEED_COLUMN_TORRENTLINK];
            seed.favorite = [rs boolForColumn:TABLE_SEED_COLUMN_FAVORITE];
            seed.mosaic = [rs boolForColumn:TABLE_SEED_COLUMN_MOSAIC];
            seed.hash = [rs stringForColumn:TABLE_SEED_COLUMN_HASH];
            seed.memo = [rs stringForColumn:TABLE_SEED_COLUMN_MEMO];
            
            NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
            [sql appendString:TABLE_SEEDPICTURE];
            [sql appendString:@" WHERE "];
            [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID];
            [sql appendString:@" = "];
            [sql appendString:[NSString stringWithFormat:@"%d", seed.localId]];
            
            FMResultSet* seedPictureResultSet = [db executeQuery:sql];
            NSMutableArray* pictureArray = [NSMutableArray arrayWithCapacity:0];
            if (nil != seedPictureResultSet)
            {
                while ([seedPictureResultSet next])
                {
                    SeedPicture* seedPicture = [[SeedPicture alloc] init];
                    
                    seedPicture.pictureId = [seedPictureResultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
                    seedPicture.seedLocalId = [seedPictureResultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID];
                    seedPicture.seedId = [seedPictureResultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDID];
                    seedPicture.pictureLink = [seedPictureResultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
                    seedPicture.memo = [seedPictureResultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_MEMO];
                    
                    [pictureArray addObject:seedPicture];
                }
            }
            [seedPictureResultSet close];
            seed.seedPictures = pictureArray;
            
            [array addObject:seed];
        }
    }
    
    return array;
}

-(Seed*) resultSet2Seed:(FMResultSet*) rs databaseHandler:(FMDatabase *)db
{
    Seed* seed;
    
    NSArray* seedList = [self resultSet2SeedList:rs databaseHandler:db];
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
        [sql appendString:TABLE_SEED_COLUMN_LOCALID];
        [sql appendString:@") from "];
        [sql appendString:TABLE_SEED];
        
        count = [db intForQuery:sql];
        
        [db close];
    }];
    
    return count;
}

-(NSInteger) countSeedsByDate:(NSDate*) date
{
    __block NSInteger count = 0;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
     {
         [db open];
         
         NSMutableString* sql = [NSMutableString stringWithString:@"select count("];
         [sql appendString:TABLE_SEED_COLUMN_LOCALID];
         [sql appendString:@") from "];
         [sql appendString:TABLE_SEED];
         [sql appendString:@" where "];
         [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
         [sql appendString:@" = "];
         [sql appendString:@"'"];
         NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:date];
         [sql appendString:dateStr];
         [sql appendString:@"'"];
         
         count = [db intForQuery:sql];
         BOOL hadError = [db hadError];
         if (hadError)
         {
             DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
         }
         
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
        array = [self resultSet2SeedList:resultSet databaseHandler:db];

        [resultSet close];
        [db close];
    }];
    
    return array;
}

-(NSArray*) getSeedsByDate:(NSDate*) date
{
    __block NSArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
     {
         [db open];
         
         NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
         [sql appendString:TABLE_SEED];
         [sql appendString:@" where "];
         [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
         [sql appendString:@" = "];
         [sql appendString:@"'"];
         NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:date];
         [sql appendString:dateStr];
         [sql appendString:@"'"];         
         
         FMResultSet* resultSet = [db executeQuery:sql];
         array = [self resultSet2SeedList:resultSet databaseHandler:db];
         
         [resultSet close];
         [db close];
     }];
    
    return array;
}

-(NSArray*) getSeedsByDates:(NSArray*) dateList
{
    NSMutableArray* seeds = [NSMutableArray array];
    
    if (nil != dateList && 0 < dateList.count)
    {
        for (NSDate* date in dateList)
        {
            NSArray* seedsByDate = [self getSeedsByDate:date];
            [seeds addObjectsFromArray:seedsByDate];
        }
    }
    
    return seeds;
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
                 [sql appendString:@":"];
                 [sql appendString:key];
                 if (1 < paramCount)
                 {
                     [sql appendString:@", "];
                 }
                 
                 paramCount--;
             }];
             
             [sql appendString:@" WHERE "];
             [sql appendString:TABLE_SEED_COLUMN_LOCALID];
             [sql appendString:@" = "];
             [sql appendString:@"'"];
             [sql appendString:[NSString stringWithFormat: @"%d", seedId]];
             [sql appendString:@"'"];
             
             flag = [db executeUpdate:sql withParameterDictionary:paramDic];
             
             [db close];
         }];
    }
    
    return flag;
}

-(NSInteger) countFavoriteSeeds
{
    __block NSInteger count = 0;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
     {
         [db open];
         
         NSMutableString* sql = [NSMutableString stringWithString:@"select count("];
         [sql appendString:TABLE_SEED_COLUMN_LOCALID];
         [sql appendString:@") from "];
         [sql appendString:TABLE_SEED];
         [sql appendString:@" where favorite = '1'"];
         
         count = [db intForQuery:sql];
         BOOL hadError = [db hadError];
         if (hadError)
         {
             DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
         }
         
         [db close];
     }];
    
    return count;
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
        array = [self resultSet2SeedList:resultSet databaseHandler:db];
        
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
        
        flag = [self updateSeed:seed.localId withParameterDictionary:paramDic];
    }
    
    return flag;
}

-(BOOL) deleteSeedsByDate:(NSDate*) date
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        if (nil != date)
        {
            flag = [db executeUpdate:SQL_FOREIGN_KEY_ENABLE];
            
            NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
            [sql appendString:TABLE_SEED];
            [sql appendString:@" where "];
            [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
            [sql appendString:@" = "];
            [sql appendString:@"'"];
            NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:date];
            [sql appendString:dateStr];
            [sql appendString:@"'"];
            
            flag = [db executeUpdate:sql];
            BOOL hadError = [db hadError];
            if (hadError)
            {
                DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            if (!flag)
            {
                DLog(@"Fail to delete seed records with date: %@", dateStr);
            }
        }
        
        [db close];
    }];
    
    return flag;
}

-(BOOL) deleteAllExceptLastThreeDaySeeds:(NSArray*) last3Days
{
    __block BOOL flag = NO;
    
    if (nil != last3Days && 3 == last3Days.count)
    {
        [databaseQueue inDatabase:^(FMDatabase* db)
         {
             [db open];
             
             flag = [db executeUpdate:SQL_FOREIGN_KEY_ENABLE];
             
             NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
             [sql appendString:TABLE_SEED];
             [sql appendString:@" where "];
//             [sql appendString:TABLE_SEED_COLUMN_FAVORITE];
//             [sql appendString:@" = "];
//             [sql appendString:@"'"];
//             [sql appendString:[NSString stringWithFormat:@"%d", 0]];
//             [sql appendString:@"'"];
             NSUInteger index = 0;
             for (NSDate* day in last3Days)
             {
                 NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
                 
                 if (0 < index)
                 {
                     [sql appendString:@" and "];                        
                 }
                 [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
                 [sql appendString:@" <> "];
                 [sql appendString:@"'"];
                 [sql appendString:dayStr];
                 [sql appendString:@"'"];
                 
                 index++;
             }
             
             flag = [db executeUpdate:sql];
             BOOL hadError = [db hadError];
             if (hadError)
             {
                 DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
             }
             if (!flag)
             {
                 DLog(@"Fail to delete all un-favorite seed records.");
             }
             
             [db close];
         }];
    }
    
    return flag;
}

-(BOOL) deleteUnFavoriteSeeds
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
     {
         [db open];
         
         flag = [db executeUpdate:SQL_FOREIGN_KEY_ENABLE];
         
         NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
         [sql appendString:TABLE_SEED];
         [sql appendString:@" where "];
         [sql appendString:TABLE_SEED_COLUMN_FAVORITE];
         [sql appendString:@" = "];
         [sql appendString:@"'"];
         [sql appendString:[NSString stringWithFormat:@"%d", 0]];
         [sql appendString:@"'"];
             
         flag = [db executeUpdate:sql];
         BOOL hadError = [db hadError];
         if (hadError)
         {
             DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
         }
         if (!flag)
         {
             DLog(@"Fail to delete all un-favorite seed records.");
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
        
        flag = [db executeUpdate:SQL_FOREIGN_KEY_ENABLE];
        
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
        
    [databaseQueue inTransaction:^(FMDatabase* db, BOOL* rollback)
    {
        [db open];
        
        if (nil != seed)
        {
            NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
            [sql appendString:TABLE_SEED];
            [sql appendString:@" ("];
            [sql appendString:TABLE_SEED_COLUMN_SEEDID];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_TYPE];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_SOURCE];
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
            [sql appendString:@"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"];
            [sql appendString:@")"];
            
            NSNumber* oSeedId = [NSNumber numberWithInteger:seed.seedId];
            flag = [db executeUpdate:sql, oSeedId, seed.type, seed.source, seed.publishDate, seed.name, seed.size, seed.format, seed.torrentLink, (seed.favorite) ? @"1" : @"0", (seed.mosaic) ? @"1" : @"0", seed.hash, seed.memo];
            BOOL hadError = [db hadError];
            if (hadError)
            {
                DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }

            [db close];
            [db open];
            
            if (flag)
            {
                sql = [NSMutableString stringWithCapacity:0];
                [sql appendString:@"select max("];
                [sql appendString:TABLE_SEED_COLUMN_LOCALID];
                [sql appendString:@") from "];
                [sql appendString:TABLE_SEED];
                
                FMResultSet* resultSet = [db executeQuery:sql];
                if ([resultSet next])
                {
                    NSInteger maxSeedId = [resultSet intForColumnIndex:0];
                    
                    NSArray* seedPictures = seed.seedPictures;
                    if (nil != seedPictures)
                    {
                        for (SeedPicture* picture in seedPictures)
                        {
                            if (nil != picture)
                            {
                                // NOTE: Can't use NSInteger or int here as FMDB issue
                                NSNumber* oSeedLocalId = [NSNumber numberWithInteger:maxSeedId];
                                NSNumber* oSeedId = [NSNumber numberWithInteger:picture.seedId];
                                
                                NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
                                [sql appendString:TABLE_SEEDPICTURE];
                                [sql appendString:@" ("];
                                [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID];
                                [sql appendString:@", "];                                
                                [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDID];
                                [sql appendString:@", "];
                                [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
                                [sql appendString:@", "];
                                [sql appendString:TABLE_SEEDPICTURE_COLUMN_MEMO];
                                [sql appendString:@") values ("];
                                [sql appendString:@"?, ?, ?, ?"];
                                [sql appendString:@")"];
                                
                                flag = [db executeUpdate:sql, oSeedLocalId, oSeedId, picture.pictureLink, picture.memo];
                                hadError = [db hadError];
                                if (hadError)
                                {
                                    DLog(@"FMDatabase error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                                }
                            }
                            else
                            {
                                DLog(@"Seed picture object is ignored as nil.");
                            }
                        }
                    }
                }
                else
                {
                    DLog(@"Fail to insert seed picture record.");
                    [db rollback];
                }
            }
            else
            {
                DLog(@"Fail to insert seed record with name: %@", seed.name);
            }
        }
        
        [db close];
    }];
    
    return flag;
}

-(BOOL) insertSeeds:(NSArray*) seeds
{
    BOOL flag = NO;
    
    for (Seed* seed in seeds)
    {
        BOOL flagOfOneTime = [self insertSeed:seed];
        flag = flagOfOneTime ? YES : NO;
    }
    
    return flag;
}

@end
