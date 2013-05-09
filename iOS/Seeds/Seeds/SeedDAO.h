//
//  SeedDAO.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DAO.h"
#import "Seed.h"

#define TABLE_SEED @"seed"
#define TABLE_SEED_COLUMN_SEEDID @"seedId"
#define TABLE_SEED_COLUMN_TYPE @"type"
#define TABLE_SEED_COLUMN_SOURCE @"source"
#define TABLE_SEED_COLUMN_PUBLISHDATE @"publishDate"
#define TABLE_SEED_COLUMN_NAME @"name"
#define TABLE_SEED_COLUMN_SIZE @"size"
#define TABLE_SEED_COLUMN_FORMAT @"format"
#define TABLE_SEED_COLUMN_TORRENTLINK @"torrentLink"
#define TABLE_SEED_COLUMN_FAVORITE @"favorite"
#define TABLE_SEED_COLUMN_HASH @"hash"
#define TABLE_SEED_COLUMN_MOSAIC @"mosaic"
#define TABLE_SEED_COLUMN_MEMO @"memo"

@protocol SeedDAO <NSObject, DAO>

-(NSArray*) resultSet2SeedList:(FMResultSet*) rs;
-(Seed*) resultSet2Seed:(FMResultSet*) rs;

-(NSInteger) countAllSeeds;
-(NSArray*) getAllSeeds;
-(BOOL) updateSeed:(NSInteger) seedId withParameterDictionary:(NSMutableDictionary*) paramDic; // paramDic should only be used for key(NSString*)=value(NSString*)
-(BOOL) deleteSeedsByDate:(NSDate*) date;
-(BOOL) deleteAllSeeds;
-(BOOL) insertSeed:(Seed*) seed;
-(BOOL) insertSeeds:(NSArray*) seeds;

-(NSArray*) getFavoriteSeeds;
-(BOOL) favoriteSeed:(Seed*) seed andFlag:(BOOL) favorite;

@end
