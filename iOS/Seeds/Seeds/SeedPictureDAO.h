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

#define TABLE_SEEDPICTURE @"seedpicture"
#define TABLE_SEEDPICTURE_COLUMN_PICTUREID @"pictureId"
#define TABLE_SEEDPICTURE_COLUMN_SEEDID @"seedId"
#define TABLE_SEEDPICTURE_COLUMN_PICTURELINK @"pictureLink"
#define TABLE_SEEDPICTURE_COLUMN_MEMO @"memo"

@protocol SeedPictureDAO <NSObject, DAO>

-(NSInteger) countAllSeedPictures;
-(NSArray*) getAllSeedPictures;
-(BOOL) updateSeedPicture:(NSInteger) seedPictureId withParameterDictionary:(NSMutableDictionary*) paramDic; // paramDic should only be used for key(NSString*)=value(NSString*)
-(NSArray*) getSeedPicturesBySeedId:(NSInteger) seedId;
-(BOOL) deleteSeedPicturesBySeedId:(NSInteger) seedId;
-(BOOL) deleteAllSeedPictures;
-(BOOL) insertSeedPicture:(SeedPicture*) seedPictures;

@end
