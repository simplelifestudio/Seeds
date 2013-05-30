//
//  SeedPictureDAO.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DAO.h"
#import "SeedPicture.h"

@protocol SeedPictureDAO <NSObject, DAO>

-(NSInteger) countAllSeedPictures;
-(NSArray*) getAllSeedPictures;
-(SeedPicture*) getFirstSeedPicture:(NSInteger) seedId;
-(BOOL) updateSeedPicture:(NSInteger) seedPictureId withParameterDictionary:(NSMutableDictionary*) paramDic; // paramDic should only be used for key(NSString*)=value(NSString*)
-(NSArray*) getSeedPicturesBySeedId:(NSInteger) seedId;
-(BOOL) deleteSeedPicturesBySeedId:(NSInteger) seedId;
-(BOOL) deleteAllSeedPictures;
-(BOOL) insertSeedPicture:(SeedPicture*) seedPicture;
-(BOOL) insertSeedPictures:(NSArray*) seedPictures;

@end
