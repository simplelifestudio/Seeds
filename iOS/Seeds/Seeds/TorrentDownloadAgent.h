//
//  TorrentDownloadAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASEURL_TORRENT @"http://www.maxp2p.com/"
#define BASEURL_TORRENTCODE @"http://www.maxp2p.com/link.php?ref="
#define FORM_ATTRKEY_REF @"ref"

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

-(id) initWithTorrentLink:(NSString*) torrentLink downloadPath:(NSString*) path;

-(void) download:(TorrentDownloadSuccessBlock) successBlock failBlock:(TorrentDownloadFailBlock) failBlock;
-(void) downloadWithDelegate:(id<TorrentDownloadAgentDelegate>) delegate;

@end
