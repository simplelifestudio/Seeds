//
//  SeedPictureDAOSQLiteImpl.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureDAOFmdbImpl.h"

@interface SeedPictureDAOFmdbImpl()
{
    __weak FMDatabaseQueue* databaseQueue;
}

-(NSArray*) resultSet2SeedPictureList:(FMResultSet*) rs;
-(Seed*) resultSet2SeedPicture:(FMResultSet*) rs;

@end

@implementation SeedPictureDAOFmdbImpl

-(void) attachDatabaseHandler:(id) handler
{
    if (nil != handler && [handler isKindOfClass:[FMDatabaseQueue class]])
    {
        databaseQueue = handler;
    }
}

-(NSArray*) resultSet2SeedPictureList:(FMResultSet*) rs
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != rs)
    {
        while ([rs next])
        {
            SeedPicture* seedPicture = [[SeedPicture alloc] init];
            
            seedPicture.pictureId = [rs intForColumn:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
            seedPicture.seedLocalId = [rs intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID];
            seedPicture.seedId = [rs intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDID];
            seedPicture.pictureLink = [rs stringForColumn:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
            seedPicture.memo = [rs stringForColumn:TABLE_SEEDPICTURE_COLUMN_MEMO];
            
            [array addObject:seedPicture];
        }
    }
    
    return array;
}

-(SeedPicture*) resultSet2SeedPicture:(FMResultSet*) rs
{
    SeedPicture* seedPicture;
    
    NSArray* seedPictureList = [self resultSet2SeedPictureList:rs];
    if (0 < seedPictureList.count)
    {
        seedPicture = [seedPictureList objectAtIndex:0];
    }
    
    return seedPicture;
}

-(NSInteger) countAllSeedPictures
{
    __block NSInteger count = 0;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select count("];
        [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
        [sql appendString:@") from "];
        [sql appendString:TABLE_SEEDPICTURE];
        
        count = [db intForQuery:sql];
        
        [db close];
    }];
    
    return count;
}

-(NSArray*) getAllSeedPictures
{
    __block NSArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
        [sql appendString:TABLE_SEEDPICTURE];
        
        FMResultSet* resultSet = [db executeQuery:sql];
        array = [self resultSet2SeedPictureList:resultSet];
        
        [resultSet close];
        [db close];
    }];
    
    return array;
}

-(SeedPicture*) getFirstSeedPicture:(NSInteger) seedId
{
    SeedPicture* seedPicture = nil;
    
    NSArray* seedPictures = [self getSeedPicturesBySeedId:seedId];
    if (0 < seedPictures.count)
    {
        seedPicture = [seedPictures objectAtIndex:0];
    }
    
    return seedPicture;
}

-(BOOL) updateSeedPicture:(NSInteger) seedPictureId withParameterDictionary:(NSMutableDictionary*) paramDic
{
    __block BOOL flag = NO;
    
    if (nil != paramDic && 0 < paramDic.count)
    {
        [databaseQueue inDatabase:^(FMDatabase* db)
         {
             [db open];
             
             __block NSMutableString* sql = [NSMutableString stringWithString:@"update "];
             [sql appendString:TABLE_SEEDPICTURE];
             [sql appendString:@" set "];
             
             __block NSInteger paramCount = paramDic.count;
             [paramDic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop)
              {
                  [sql appendString:key];
                  [sql appendString:@" = "];
                  [sql appendString:[NSString stringWithFormat:@"%@", value]];
                  if (0 < paramCount)
                  {
                      [sql appendString:@", "];
                  }
                  
                  paramCount--;
              }];
             
             [sql appendString:@" WHERE "];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
             [sql appendString:@" = "];
             [sql appendString:[NSString stringWithFormat: @"%d", seedPictureId]];
             
             flag = [db executeUpdate:sql];
             
             [db close];
         }];
    }
    
    return flag;
}

-(NSArray*) getSeedPicturesBySeedId:(NSInteger) seedId
{
    __block NSArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        if (0 < seedId)
        {
            NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
            [sql appendString:TABLE_SEEDPICTURE];
            [sql appendString:@" WHERE "];
            [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDID];
            [sql appendString:@" = "];
            [sql appendString:[NSString stringWithFormat:@"%d", seedId]];
            
            FMResultSet* resultSet = [db executeQuery:sql];
            array = [self resultSet2SeedPictureList:resultSet];
            [resultSet close];
        }
        
        [db close];
    }];
    
    return array;
}

-(BOOL) deleteSeedPicturesBySeedId:(NSInteger) seedId
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
        [sql appendString:TABLE_SEEDPICTURE];
        [sql appendString:@" WHERE "];
        [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDID];
        [sql appendString:@" = "];
        [sql appendString:[NSString stringWithFormat:@"%d", seedId]];
        
        flag = [db executeUpdate:sql];
        
        [db close];
    }];
    
    return flag;
}

-(BOOL) deleteAllSeedPictures
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"delete from "];
        [sql appendString:TABLE_SEEDPICTURE];
        
        flag = [db executeUpdate:sql];

        [db close];
    }];
    
    return flag;
}

-(BOOL) insertSeedPicture:(SeedPicture *)seedPicture
{
    __block BOOL flag = NO;
    
    [databaseQueue inDatabase:^(FMDatabase* db)
     {
         [db open];
         
         if (nil != seedPicture)
         {
             NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
             [sql appendString:TABLE_SEEDPICTURE];
             [sql appendString:@" ("];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
             [sql appendString:@", "];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID];
             [sql appendString:@", "];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDID];
             [sql appendString:@", "];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
             [sql appendString:@", "];
             [sql appendString:TABLE_SEEDPICTURE_COLUMN_MEMO];
             [sql appendString:@") values ("];
             [sql appendString:@"?, ?, ?, ?, ?"];
             [sql appendString:@")"];
             
             // NOTE: Can't use NSInteger or int here as FMDB issue
             NSNumber* oSeedLocalId = [NSNumber numberWithInteger:seedPicture.seedLocalId];
             NSNumber* oSeedId = [NSNumber numberWithInteger:seedPicture.seedId];
             flag = [db executeUpdate:sql, seedPicture.pictureId, oSeedLocalId, oSeedId, seedPicture.pictureLink, seedPicture.memo];
         }
         
         [db close];
     }];
    
    return flag;
}

-(BOOL) insertSeedPictures:(NSArray*) seedPictures
{
    return NO;
}

@end
