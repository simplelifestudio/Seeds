//
//  TorrentDownloadAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@protocol TorrentDownloadAgentDelegate <NSObject>

@required
-(void) torrentDownloadStarted:(Seed*) seed;
-(void) torrentDownloadFinished:(Seed*) seed;
-(void) torrentDownloadFailed:(Seed*) seed error:(NSError*) error;
-(void) torrentSaveFinished:(Seed*) seed filePath:(NSString*) filePath;
-(void) torrentSaveFailed:(Seed*) seed filePath:(NSString*) filePath;

@end

@interface TorrentDownloadAgent : NSObject

typedef void (^TorrentDownloadSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^TorrentDownloadFailBlock)(AFHTTPRequestOperation *operation, NSError *error);

@property (nonatomic, strong) id<TorrentDownloadAgentDelegate> delegate;

+(NSString*) torrentCode:(Seed*) seed;
+(NSString*) torrentFileName:(Seed*) seed;
+(NSString*) torrentFileNameBySeedLocalId:(NSInteger) localId;
+(NSString*) torrentFileFullPath:(Seed*) seed;
+(NSString*) torrentFileFullPathBySeedLocalId:(NSInteger) localId;

-(id) initWithSeed:(Seed*) seed downloadPath:(NSString*) path;

-(void) download:(TorrentDownloadSuccessBlock) successBlock failBlock:(TorrentDownloadFailBlock) failBlock;
-(void) downloadWithDelegate:(id<TorrentDownloadAgentDelegate>) delegate;

@end
