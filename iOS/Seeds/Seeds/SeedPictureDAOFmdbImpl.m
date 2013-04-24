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

@end

@implementation SeedPictureDAOFmdbImpl

-(void) attachDatabaseHandler:(id) handler
{
    if (nil != handler && [handler isKindOfClass:[FMDatabaseQueue class]])
    {
        databaseQueue = handler;
    }
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
    __block NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
    [databaseQueue inDatabase:^(FMDatabase* db)
    {
        [db open];
        
        NSMutableString* sql = [NSMutableString stringWithString:@"select * from "];
        [sql appendString:TABLE_SEEDPICTURE];
        
        FMResultSet* resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            SeedPicture* seedPicture = [[SeedPicture alloc] init];
            
            seedPicture.pictureId = [resultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
            seedPicture.seedId = [resultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDID];
            seedPicture.pictureLink = [resultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
            seedPicture.memo = [resultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_MEMO];
            
            [array addObject:seedPicture];
        }
        
        [db close];
    }];
    
    return array;
}

-(NSArray*) getSeedPicturesBySeedId:(NSInteger) seedId
{
    __block NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    
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
            while ([resultSet next])
            {
                SeedPicture* seedPicture = [[SeedPicture alloc] init];
                
                seedPicture.pictureId = [resultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
                seedPicture.seedId = [resultSet intForColumn:TABLE_SEEDPICTURE_COLUMN_SEEDID];
                seedPicture.pictureLink = [resultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
                seedPicture.memo = [resultSet stringForColumn:TABLE_SEEDPICTURE_COLUMN_MEMO];
                
                [array addObject:seedPicture];
            }
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
             if (nil != seedPicture)
             {
                 NSMutableString* sql = [NSMutableString stringWithString:@"insert into "];
                 [sql appendString:TABLE_SEEDPICTURE];
                 [sql appendString:@" ("];
                 [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTUREID];
                 [sql appendString:@", "];
                 [sql appendString:TABLE_SEEDPICTURE_COLUMN_SEEDID];
                 [sql appendString:@", "];
                 [sql appendString:TABLE_SEEDPICTURE_COLUMN_PICTURELINK];
                 [sql appendString:@", "];
                 [sql appendString:TABLE_SEEDPICTURE_COLUMN_MEMO];
                 [sql appendString:@") values ("];
                 [sql appendString:@"?, ?, ?, ?"];
                 [sql appendString:@")"];
                 
                 flag = [db executeUpdate:sql, seedPicture.pictureId, seedPicture.seedId, seedPicture.pictureLink, seedPicture.memo];
             }
         }
         
         [db close];
     }];
    
    return flag;
}

@end
