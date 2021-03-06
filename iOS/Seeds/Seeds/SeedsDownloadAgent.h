//
//  SeedsDownloadAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-19.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBSharedInstance.h"
#import "TorrentDownloadAgent.h"

typedef enum {SeedNotDownload, SeedWaitForDownload, SeedIsDownloading, SeedDownloaded, SeedDownloadFailed} SeedDownloadStatus;

@interface SeedsDownloadAgent : NSObject <CBSharedInstance>

+(NSString*) downloadPath;

-(void) downloadSeed:(Seed*) seed;
-(void) downloadSeeds:(NSArray*) seeds;

-(void) deleteDownloadedSeed:(Seed*) seed;
-(void) deleteDownloadedSeeds:(NSArray*) seeds;

-(NSUInteger) downloadedSeedCount;
-(NSArray*) downloadedSeedLocalIdList;
-(NSArray*) downloadedSeedList;
-(NSArray*) totalSeedLocalLidList;
-(NSArray*) totalSeedList;

-(SeedDownloadStatus) checkDownloadStatus:(Seed*) seed;

-(void) clearDownloadDirectory:(NSArray*) last3Days;
-(void) resetAgent;

@end
