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
    NSInteger torrentCounts;
    NSInteger torrentIndex;
    NSInteger failedCount;
}

@property (atomic, strong) NSMutableArray* torrentDownloadAgentList;

@end

@implementation TorrentListDownloadAgent

@synthesize singleDownloadDelegate = _singleDownloadDelegate;
@synthesize listDownloadDelegate = _listDownloadDelegate;

@synthesize torrentDownloadAgentList = _torrentDownloadAgentList;

-(id) init
{
    self = [super init];
    if (self)
    {
        _torrentDownloadAgentList = [NSMutableArray arrayWithCapacity:0];
        torrentCounts = 0;
        torrentIndex = 0;
        failedCount = 0;
    }
    return self;
}

-(void) addSeeds:(NSArray *)seeds downloadPath:(NSString *)path
{
    [self addTorrentDownloadAgentList:seeds downloadPath:path];
}

-(void) downloadWithDelegate:(id<TorrentListDownloadAgentDelegate>) listDelegate
{
    _listDownloadDelegate = listDelegate;
    _singleDownloadDelegate = self;
    
    torrentCounts = _torrentDownloadAgentList.count;
    if (0 == torrentCounts)
    {
        if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadFinished:)])
        {
            [_listDownloadDelegate torrentListDownloadFinished:NSLocalizedString(@"Sync Yet", nil)];
        }
    }
    else
    {
        if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadStarted:)])
        {
            [_listDownloadDelegate torrentListDownloadStarted:NSLocalizedString(@"Torrents Downloading", nil)];
        }
        
        [self launchNextTorrentDownloadProcess];
    }
}

-(void) launchNextTorrentDownloadProcess
{
    if (0 < _torrentDownloadAgentList.count)// && 4 > torrentIndex)
    {
        torrentIndex += 1;
        TorrentDownloadAgent* torrentDownloadAgent = [_torrentDownloadAgentList objectAtIndex:0];
        [torrentDownloadAgent downloadWithDelegate:self];
        [_torrentDownloadAgentList removeObjectAtIndex:0];
    }
    else
    {
        if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadFinished:)])
        {
            [_listDownloadDelegate torrentListDownloadFinished:NSLocalizedString(@"Completed", nil)];
        }        
    }
}

-(void) torrentDownloadStarted:(NSString*) torrentCode
{
//    DLog(@"Started to download torrent with code:%@", torrentCode);
}

-(void) torrentDownloadFinished:(NSString*) torrentCode
{
//    DLog(@"Finished to download torrent with code:%@", torrentCode);
}

-(void) torrentDownloadFailed:(NSString*) torrentCode error:(NSError*) error
{
    DLog(@"Failed to download torrent with code:%@ for error:%@", torrentCode, [error description]);
    failedCount += 1;
}

-(NSString*) computeMinorStatusString
{
    NSMutableString* minorStatus = [NSMutableString string];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", torrentIndex]];
    [minorStatus appendString:@" of "];
    [minorStatus appendString:[NSString stringWithFormat:@"%d", torrentCounts]];

    if (0 < failedCount)
    {
        [minorStatus appendString:@" (ERR:"];
        [minorStatus appendString:[NSString stringWithFormat:@"%d", failedCount]];
        [minorStatus appendString:@")"];
    }
    
    return minorStatus;
}

-(void) torrentSaveFinished:(NSString*) torrentCode filePath:(NSString*) filePath
{
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:minorStatus:)])
    {
        NSString* majorStatus = NSLocalizedString(@"Torrents Downloading", nil);
        NSString* minorStatus = [self computeMinorStatusString];
        [_listDownloadDelegate torrentListDownloadInProgress:majorStatus minorStatus:minorStatus];
    }
    
    [self launchNextTorrentDownloadProcess];
}

-(void) torrentSaveFailed:(NSString*) torrentCode filePath:(NSString*) filePath
{
    DLog(@"Failed to save torrent file with code:%@ in path:%@", torrentCode, filePath);
    failedCount += 1;    
    if ([_listDownloadDelegate respondsToSelector:@selector(torrentListDownloadInProgress:minorStatus:)])
    {
        NSString* majorStatus = NSLocalizedString(@"Torrents Downloading", nil);
        NSString* minorStatus = [self computeMinorStatusString];
        [_listDownloadDelegate torrentListDownloadInProgress:majorStatus minorStatus:minorStatus];
    }
    [self launchNextTorrentDownloadProcess];
}

-(void) addTorrentDownloadAgentList:(NSArray*) seeds downloadPath:(NSString*)path
{
    NSAssert(nil != seeds, @"TorrentL links array can't be nil.");
    NSAssert(nil != path, @"Download path can't be nil.");
    
    for (Seed* seed in seeds)
    {
        TorrentDownloadAgent* torrentDownloadAgent = [[TorrentDownloadAgent alloc] initWithSeed:seed downloadPath:path];
        [_torrentDownloadAgentList addObject:torrentDownloadAgent];
    }
}

@end
