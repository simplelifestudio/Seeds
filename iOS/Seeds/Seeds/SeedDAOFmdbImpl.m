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
    __block NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
        [sql appendString:TABLE_SEED];
        
        FMResultSet* resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            Seed* seed = [[Seed alloc] init];
            
            seed.seedId = [resultSet intForColumn:TABLE_SEED_COLUMN_SEEDID];
            seed.type = [resultSet stringForColumn:TABLE_SEED_COLUMN_TYPE];
            seed.publishDate = [resultSet stringForColumn:TABLE_SEED_COLUMN_PUBLISHDATE];
            seed.name = [resultSet stringForColumn:TABLE_SEED_COLUMN_NAME];
            seed.size = [resultSet stringForColumn:TABLE_SEED_COLUMN_SIZE];
            seed.format = [resultSet stringForColumn:TABLE_SEED_COLUMN_FORMAT];
            seed.torrentLink = [resultSet stringForColumn:TABLE_SEED_COLUMN_TORRENTLINK];
            seed.favorite = [resultSet boolForColumn:TABLE_SEED_COLUMN_FAVORITE];
            seed.mosaic = [resultSet boolForColumn:TABLE_SEED_COLUMN_MOSAIC];
            seed.hash = [resultSet stringForColumn:TABLE_SEED_COLUMN_HASH];
            seed.memo = [resultSet stringForColumn:TABLE_SEED_COLUMN_MEMO];
            
            [array addObject:seed];
        }
        
        [db close];
    }];
    
    return array;
}

-(BOOL) updateSeed:(Seed*) seed
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        if (nil != seed)
        {
            NSMutableDictionary* dictionaryArgs = [NSMutableDictionary dictionary];
            
            [dictionaryArgs setObject:@"NewText1" forKey:@"a"];
            [dictionaryArgs setObject:@"NewText2" forKey:@"b"];
            [dictionaryArgs setObject:@"OneMoreText" forKey:@"OneMore"];
            
            NSMutableString* sql = [NSMutableString stringWithString:@"update "];
            [sql appendString:TABLE_SEED];
            [sql appendString:@" set "];
            [sql appendString:TABLE_SEED_COLUMN_TYPE];
            [sql appendString:@" = "];
            [sql appendString:seed.type];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_PUBLISHDATE];
            [sql appendString:@" = "];
            [sql appendString:seed.publishDate];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_NAME];
            [sql appendString:@" = "];
            [sql appendString:seed.name];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_SIZE];
            [sql appendString:@" = "];
            [sql appendString:seed.size];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_FORMAT];
            [sql appendString:@" = "];
            [sql appendString:seed.format];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_TORRENTLINK];
            [sql appendString:@" = "];
            [sql appendString:seed.torrentLink];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_FAVORITE];
            [sql appendString:@" = "];
            [sql appendString:(seed.favorite) ? @"1" : @"0"];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_MOSAIC];
            [sql appendString:@" = "];
            [sql appendString:(seed.mosaic) ? @"1" : @"0"];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_HASH];
            [sql appendString:@" = "];
            [sql appendString:seed.hash];
            [sql appendString:@", "];
            [sql appendString:TABLE_SEED_COLUMN_MEMO];
            [sql appendString:@" = "];
            [sql appendString:seed.memo];
            [sql appendString:@" WHERE "];
            [sql appendString:TABLE_SEED_COLUMN_SEEDID];
            [sql appendString:@" = "];
            [sql appendString:[NSString stringWithFormat: @"%d", seed.seedId]];
            
            flag = [db executeUpdate:sql];
        }
        
        [db close];
    }];
    
    return flag;
}

-(BOOL) favoriteSeed:(Seed*) seed andFlag:(BOOL) favorite
{
    BOOL flag = NO;
    
    if (nil != seed)
    {
        seed.favorite = favorite;
        
        flag = [self updateSeed:seed];
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
            if (nil != seed)
            {
                NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
                [sql appendString:TABLE_SEED];
                [sql appendString:@" ("];
                [sql appendString:TABLE_SEED_COLUMN_SEEDID];
                [sql appendString:@", "];
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
                [sql appendString:@"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"];
                [sql appendString:@")"];
                
                flag = [db executeUpdate:sql, seed.seedId, seed.type, seed.publishDate, seed.name, seed.size, seed.format, seed.torrentLink, seed.favorite, seed.mosaic, seed.hash, seed.memo];
            }
        }
        
        [db close];
    }];
    
    return flag;
}

@end
