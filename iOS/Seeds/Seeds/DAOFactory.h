//
//  DAOFactory.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SeedDAO.h"
#import "SeedPictureDAO.h"

#import "SeedDAOFmdbImpl.h"
#import "SeedPictureDAOFmdbImpl.h"

@interface DAOFactory : NSObject

+(id<SeedDAO>) getSeedDAO;
+(id<SeedPictureDAO>) getSeedPictureDAO;

@end
