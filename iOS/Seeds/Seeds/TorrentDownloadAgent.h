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
-(void) torrentDownloadStarted:(NSString*) torrentCode;
-(void) torrentDownloadFinished:(NSString*) torrentCode;
-(void) torrentDownloadFailed:(NSString*) torrentCode error:(NSError*) error;
-(void) torrentSaveFinished:(NSString*) torrentCode filePath:(NSString*) filePath;
-(void) torrentSaveFailed:(NSString*) torrentCode filePath:(NSString*) filePath;

@end

@interface TorrentDownloadAgent : NSObject

typedef void (^TorrentDownloadSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^TorrentDownloadFailBlock)(AFHTTPRequestOperation *operation, NSError *error);

@property (nonatomic, strong) id<TorrentDownloadAgentDelegate> delegate;

+(NSString*) torrentCode:(Seed*) seed;
+(NSString*) torrentFileName:(Seed*) seed;
+(NSString*) torrentFileFullPath:(Seed*) seed;

-(id) initWithSeed:(Seed*) seed downloadPath:(NSString*) path;

-(void) download:(TorrentDownloadSuccessBlock) successBlock failBlock:(TorrentDownloadFailBlock) failBlock;
-(void) downloadWithDelegate:(id<TorrentDownloadAgentDelegate>) delegate;

@end
