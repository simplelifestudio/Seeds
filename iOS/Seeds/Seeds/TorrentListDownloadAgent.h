//
//  TorrentListDownloadAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-19.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TorrentDownloadAgent.h"

@protocol TorrentListDownloadAgentDelegate <NSObject>

@required

-(void) torrentListDownloadStarted;
-(void) torrentListDownloadFinished;
-(void) torrentListDownloadInProgress:(NSString*) progress;

@end

@interface TorrentListDownloadAgent : NSObject <TorrentDownloadAgentDelegate>

@property (nonatomic, strong) id<TorrentListDownloadAgentDelegate> listDownloadDelegate;
@property (nonatomic, strong) id<TorrentDownloadAgentDelegate> singleDownloadDelegate;

-(id) initWithTorrentLinks:(NSArray*) torrentLinks downloadPath:(NSString*) path;
-(void) downloadWithDelegate:(id<TorrentListDownloadAgentDelegate>) listDelegate;

@end
