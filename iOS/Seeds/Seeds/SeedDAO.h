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

@protocol SeedDAO <NSObject, DAO>

-(NSInteger) countAllSeeds;
-(NSInteger) countSeedsByDate:(NSDate*) date;

-(NSArray*) getAllSeeds;
-(NSArray*) getSeedsByLocalIds:(NSArray*) localIds;
-(Seed*) getSeedByLocalId:(NSInteger) localId;
-(NSArray*) getSeedsByDate:(NSDate*) date;
-(NSArray*) getSeedsByDates:(NSArray*) dateList;

-(BOOL) updateSeed:(NSInteger) seedId withParameterDictionary:(NSMutableDictionary*) paramDic; // paramDic should only be used for key(NSString*)=value(NSString*)
-(BOOL) deleteSeedsByDate:(NSDate*) date;
-(BOOL) deleteAllSeeds;
-(BOOL) deleteUnFavoriteSeeds;
-(BOOL) deleteAllExceptLastThreeDaySeeds:(NSArray*) last3Days;
-(BOOL) insertSeed:(Seed*) seed;
-(BOOL) insertSeeds:(NSArray*) seeds;

-(NSInteger) countFavoriteSeeds;
-(NSArray*) getFavoriteSeeds;
-(BOOL) favoriteSeed:(Seed*) seed andFlag:(BOOL) favorite;
-(BOOL) isSeedFavoritedWithLocalId:(NSInteger) localId;

@end
