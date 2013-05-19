//
//  TorrentListDownloadAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-19.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TorrentListDownloadAgent.h"

@interface TorrentListDownloadAgent()
{


}

@property (atomic, strong) NSMutableArray* torrentDownloadAgentList;

@end

@implementation TorrentListDownloadAgent

@synthesize singleDownloadDelegate = _singleDownloadDelegate;
@synthesize listDownloadDelegate = _listDownloadDelegate;

@synthesize torrentDownloadAgentList = _torrentDownloadAgentList;

-(id) initWithTorrentLinks:(NSArray *)torrentLinks downloadPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        [self initTorrentDownloadAgentList:torrentLinks downloadPath:path];
    }
    
    return self;
}

-(void) downloadWithDelegate:(id<TorrentListDownloadAgentDelegate>) listDelegate
{
    _listDownloadDelegate = listDelegate;
    _singleDownloadDelegate = self;
    
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadStarted)])
    {
        [_listDownloadDelegate torrentListDownloadStarted];
    }
    
    [self launchNextTorrentDownloadProcess];
}

-(void) launchNextTorrentDownloadProcess
{
    if (0 < _torrentDownloadAgentList.count)
    {
        TorrentDownloadAgent* torrentDownloadAgent = [_torrentDownloadAgentList objectAtIndex:0];
        [torrentDownloadAgent downloadWithDelegate:self];
    }
    else
    {
        if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadFinished)])
        {
            [_listDownloadDelegate torrentListDownloadFinished];
        }        
    }
}

-(void) torrentDownloadStarted:(NSString*) torrentCode
{
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:)])
    {
        [_listDownloadDelegate torrentListDownloadInProgress:torrentCode];
    }
}

-(void) torrentDownloadFinished:(NSString*) torrentCode
{
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:)])
    {
        [_listDownloadDelegate torrentListDownloadInProgress:torrentCode];
    }
}

-(void) torrentDownloadFailed:(NSString*) torrentCode error:(NSError*) error
{
    [self launchNextTorrentDownloadProcess];
    
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:)])
    {
        [_listDownloadDelegate torrentListDownloadInProgress:torrentCode];
    }
}

-(void) torrentSaveFinished:(NSString*) torrentCode filePath:(NSString*) filePath
{
    [self launchNextTorrentDownloadProcess];
    
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:)])
    {
        [_listDownloadDelegate torrentListDownloadInProgress:torrentCode];
    }
}

-(void) torrentSaveFailed:(NSString*) torrentCode filePath:(NSString*) filePath
{
    [self launchNextTorrentDownloadProcess];
    
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:)])
    {
        [_listDownloadDelegate torrentListDownloadInProgress:torrentCode];
    }
}

-(void) initTorrentDownloadAgentList:(NSArray*) torrentLinks downloadPath:(NSString*)path
{
    NSAssert(nil != torrentLinks, @"TorrentL links array can't be nil.");
    NSAssert(nil != path, @"Download path can't be nil.");
    
    _torrentDownloadAgentList = [NSMutableArray arrayWithCapacity:torrentLinks.count];
    for (NSString* torrentLink in torrentLinks)
    {
        TorrentDownloadAgent* torrentDownloadAgent = [[TorrentDownloadAgent alloc] initWithTorrentLink:torrentLink downloadPath:path];
        [_torrentDownloadAgentList addObject:torrentDownloadAgent];
    }
}

@end
