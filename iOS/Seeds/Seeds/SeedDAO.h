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
-(NSArray*) getAllSeeds;
-(BOOL) updateSeed:(NSInteger) seedId withParameterDictionary:(NSMutableDictionary*) paramDic; // paramDic should only be used for key(NSString*)=value(NSString*)
-(BOOL) deleteSeedsByDate:(NSDate*) date;
-(BOOL) deleteAllSeeds;
-(BOOL) deleteUnFavoriteSeeds;
-(BOOL) deleteAllSeedsExceptFavoritedOrLastThreeDayRecords:(NSArray*) last3Days;
-(BOOL) insertSeed:(Seed*) seed;
-(BOOL) insertSeeds:(NSArray*) seeds;

-(NSArray*) getFavoriteSeeds;
-(BOOL) favoriteSeed:(Seed*) seed andFlag:(BOOL) favorite;

@end
