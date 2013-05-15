//
//  SeedDAOFmdbImpl.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SeedDAO.h"

#define SQL_FOREIGN_KEY_ENABLE @"PRAGMA foreign_keys=1"

@interface SeedDAOFmdbImpl : NSObject <SeedDAO>

@end
