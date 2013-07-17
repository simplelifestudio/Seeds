//
//  SeedBuilder.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Seed.h"

@interface SeedBuilder : NSObject

+(BOOL) verfiySeed:(Seed*) seed;

-(void) initSeed;
-(void) resetSeed;
-(void) fillSeedWithAttribute:(NSString*) attrName attrVal:(NSString*)attrVal;
-(BOOL) isSeedReady;
-(Seed*) getSeed;

@end
