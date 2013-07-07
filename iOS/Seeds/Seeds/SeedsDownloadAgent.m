//
//  SeedsDownloadAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-19.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsDownloadAgent.h"

#import "CBFileUtils.h"

@interface SeedDownloadWrapper : NSObject
{

}

@property (atomic) SeedDownloadStatus status;
@property (strong, nonatomic) Seed* seed;

-(id) initWithSeed:(Seed*) seed;

@end

@implementation SeedDownloadWrapper

@synthesize status = _status;
@synthesize seed = _seed;

-(id) initWithSeed:(Seed*) seed
{
    self = [super init];
    
    if (self)
    {
        _seed = seed;
        _status = SeedWaitForDownload;
    }
    
    return self;
}

@end


@interface SeedsDownloadQueue : NSObject
{
    NSMutableArray* _queue;
    
    id<SeedDAO> _seedDAO;
}

-(void) addSeed:(Seed*) seed;
-(SeedDownloadStatus) checkSeedStatus:(Seed*) seed;
-(void) updateSeedStatus:(Seed*) seed status:(SeedDownloadStatus) status;
-(void) removeSeed:(Seed*) seed;
-(NSArray*) seedsWithStatus:(SeedDownloadStatus) status;
-(NSArray*) allSeeds;
-(void) resetQueue;
-(NSUInteger) queueLength;

@end

@implementation SeedsDownloadQueue

-(id) init
{
    self = [super init];
    
    if (self)
    {
        _seedDAO = [DAOFactory getSeedDAO];
        [self _initQueueByDownloadedTorrentFiles];
    }
    
    return self;
}

-(void) addSeed:(Seed*) seed
{
    SeedDownloadWrapper* wrapper = [self _wrapperInQueue:seed];
    if (nil == wrapper)
    {
        wrapper = [[SeedDownloadWrapper alloc] initWithSeed:seed];
        [self _syncWork:seed block:^(){
            [_queue addObject:wrapper];
        }];
    }
}

-(BOOL) _isSeedInQueue:(Seed *)seed
{
    __block BOOL flag = NO;
    
    SeedDownloadWrapper* wrapper = [self _wrapperInQueue:seed];
    flag = (nil != wrapper) ? YES : NO;
    
    return flag;
}

-(void) updateSeedStatus:(Seed*) seed status:(SeedDownloadStatus) status
{
    BOOL needNotify = NO;
    
    SeedDownloadWrapper* wrapper = [self _wrapperInQueue:seed];
    if (nil != wrapper)
    {
        wrapper.status = status;
        needNotify = YES;
    }
    
    if (needNotify)
    {
        [self _postNotification:seed status:status];
    }
}

-(void) removeSeed:(Seed *)seed
{
    if (nil != seed)
    {
        __block BOOL needNotify = NO;
        [self _syncWork:seed block:^(){
            for (SeedDownloadWrapper* w in _queue)
            {
                if (w.seed.localId == seed.localId)
                {
                    [_queue removeObject:w];
                    needNotify = YES;
                    break;
                }
            }
        }];
        if (needNotify)
        {
            [self _postNotification:seed status:SeedNotDownload];
        }
    }
}

-(SeedDownloadStatus) checkSeedStatus:(Seed*) seed
{
    SeedDownloadStatus status = SeedNotDownload;
    
    SeedDownloadWrapper* wrapper = [self _wrapperInQueue:seed];
    if (nil != wrapper)
    {
        status = wrapper.status;
    }
    
    return status;
}

-(NSArray*) seedsWithStatus:(SeedDownloadStatus) status
{
    __block NSMutableArray* seeds = [NSMutableArray array];
    
    [self _syncWork:nil block:^(){
        for (SeedDownloadWrapper* wrapper in _queue)
        {
            if (wrapper.status == status)
            {
                [seeds addObject:wrapper.seed];
            }
        }
    }];
    
    return seeds;
}

-(NSArray*) allSeeds
{
    __block NSMutableArray* seeds = [NSMutableArray array];
    
    [self _syncWork:nil block:^(){
        for (SeedDownloadWrapper* wrapper in _queue)
        {
            [seeds addObject:wrapper.seed];
        }
    }];
    
    return seeds;
}

-(void) resetQueue
{
    [self _syncWork:nil block:^(){
        [_queue removeAllObjects];    
    }];
}

-(NSUInteger) queueLength
{
    return _queue.count;
}

#pragma mark - Private Methods

-(void) _postNotification:(Seed*) seed status:(SeedDownloadStatus) status
{
    NSString* sStatus = [NSString stringWithFormat:@"%d", status];
    NSDictionary* info = [NSDictionary dictionaryWithObjects:@[seed, sStatus] forKeys:@[NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_SEED, NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_STATUS]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED object:self userInfo:info];
}

-(void) _initQueueByDownloadedTorrentFiles
{
    _queue = [NSMutableArray array];
    
    NSString* _downloadPath = [SeedsDownloadAgent downloadPath];
    NSArray* torrentFiles = [CBFileUtils filesInDirectory:_downloadPath fileExtendName:FILE_EXTENDNAME_TORRENT];
    NSMutableArray* sLocalIdList = [NSMutableArray array];
    if (nil != torrentFiles && 0 < torrentFiles.count)
    {
        for (NSString* fileFullPath in torrentFiles)
        {
            NSString* fileName = [fileFullPath lastPathComponent];
            NSString* sLocalId = [CBStringUtils replaceSubString:@"" oldSubString:FILE_EXTENDNAME_DOT_TORRENT string:fileName];
            [sLocalIdList addObject:sLocalId];
        }
    }
    
    NSArray* seedList = [_seedDAO getSeedsByLocalIds:sLocalIdList];
    for (Seed* seed in seedList)
    {
        [self addSeed:seed];
        [self updateSeedStatus:seed status:SeedDownloaded];
    }
}

-(SeedDownloadWrapper*) _wrapperInQueue:(Seed*) seed
{
    __block SeedDownloadWrapper* wrapper = nil;
    
    if (nil != seed)
    {
        [self _syncWork:seed block:^(){
            for (SeedDownloadWrapper* w in _queue)
            {
                if (w.seed.localId == seed.localId)
                {
                    wrapper = w;
                    break;
                }
            }
        }];
    }
    
    return wrapper;
}

-(void) _syncWork:(Seed*) seed block:(void(^)()) block
{
    @synchronized(_queue)
    {
        block(seed);
    }
}

@end


@interface SeedsDownloadAgent() <TorrentDownloadAgentDelegate>
{
    SeedsDownloadQueue* _downloadQueue;
    
    id<SeedDAO> _seedDAO;
}

@end

@implementation SeedsDownloadAgent

SINGLETON(SeedsDownloadAgent)

-(id) init
{
    self = [super init];
    if (self)
    {
        [self _setupInstance];
    }
    return self;
}

static NSString* _downloadPath;
static NSString* _favoritePath;
+(void) initialize
{
    NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
    _downloadPath = [documentsPath stringByAppendingPathComponent:FOLDER_TORRENTS];
    _favoritePath = [_downloadPath stringByAppendingPathComponent:FOLDER_FAVORITES];
}

+(NSString*) downloadPath
{
    return _downloadPath;
}

+(NSString*) favoritePath
{
    return _favoritePath;
}

#pragma mark - Public Methods

-(SeedDownloadStatus) checkDownloadStatus:(Seed*) seed
{
    return [_downloadQueue checkSeedStatus:seed];
}

-(void) downloadSeed:(Seed*) seed
{
    SeedDownloadStatus status = [self checkDownloadStatus:seed];
    switch (status)
    {
        case SeedNotDownload:
        {
            [_downloadQueue addSeed:seed];
            [self _downloadTorrentFile:seed];
            break;
        }
        case SeedWaitForDownload:
        {
            return;
        }
        case SeedIsDownloading:
        {
            return;
        }
        case SeedDownloaded:
        {
            return;
        }
        case SeedDownloadFailed:
        {
            [self _downloadTorrentFile:seed];
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) downloadSeeds:(NSArray*) seeds
{
    if (nil != seeds && 0 < seeds.count)
    {
        for (Seed* seed in seeds)
        {
            [self downloadSeed:seed];
        }
    }
}

-(void) deleteDownloadedSeed:(Seed*) seed
{
    SeedDownloadStatus status = [self checkDownloadStatus:seed];
    if (status != SeedNotDownload)
    {
        [_downloadQueue removeSeed:seed];
        [self _deleteTorrentFile:seed];
    }
}

-(void) deleteDownloadedSeeds:(NSArray*) seeds
{
    if (nil != seeds && 0 < seeds.count)
    {
        for (Seed* seed in seeds)
        {
            [self deleteDownloadedSeed:seed];
        }
    }
}

-(NSUInteger) downloadedSeedCount
{
    return [_downloadQueue queueLength];
}

-(NSArray*) downloadedSeedLocalIdList
{
    NSMutableArray* list = [NSMutableArray array];
    
    NSArray* seedList = [self downloadedSeedList];
    for (Seed* seed in seedList)
    {
        NSString* sLocalId = [NSString stringWithFormat:@"%d", seed.localId];
        [list addObject:sLocalId];
    }
    
    return list;
}

-(NSArray*) downloadedSeedList
{
    NSMutableArray* list = [NSMutableArray array];
    
    [list addObjectsFromArray:[_downloadQueue seedsWithStatus:SeedDownloaded]];
    
    return list;
}

-(NSArray*) totalSeedLocalLidList
{
    NSMutableArray* list = [NSMutableArray array];
    
    NSArray* seedList = [self totalSeedList];
    for (Seed* seed in seedList)
    {
        NSString* sLocalId = [NSString stringWithFormat:@"%d", seed.localId];
        [list addObject:sLocalId];
    }
    
    return list;
}

-(NSArray*) totalSeedList
{
    NSMutableArray* list = [NSMutableArray array];
    
    NSArray* _seedsInQueue = [_downloadQueue allSeeds];
    for (int i = _seedsInQueue.count - 1; 0 <= i; i--)
    {
       Seed* seed = [_seedsInQueue objectAtIndex:i];
        [list addObject:seed];
    }
    
    return list;
}

-(void) clearDownloadDirectory:(NSArray*) last3Days
{
    NSArray* last3DayStrs = [CBDateUtils lastThreeDayStrings:last3Days formatString:STANDARD_DATE_FORMAT];
    
    NSMutableString* downloadDirPath = [NSMutableString string];
    [downloadDirPath appendString:_downloadPath];
    NSArray* subDirs = [CBFileUtils directories:downloadDirPath];

    for (NSString* subDirPath in subDirs)
    {
        NSString* path = [subDirPath lastPathComponent];
        
        BOOL flag = NO;
        for (NSString* dayStr in last3DayStrs)
        {
            if ([dayStr isEqualToString:path])
            {
                flag = YES;
                break;
            }
        }

        if (!flag)
        {
            NSMutableString* subDirFullPath = [NSMutableString stringWithString:downloadDirPath];
            [subDirFullPath appendString:@"/"];
            [subDirFullPath appendString:subDirPath];
            [CBFileUtils deleteDirectory:subDirFullPath];
        }
    }
}

-(void) resetAgent
{
    [_downloadQueue resetQueue];
    
    NSArray* files = [CBFileUtils filesInDirectory:_downloadPath fileExtendName:FILE_EXTENDNAME_TORRENT];
    for (NSString* fileFullPath in files)
    {
        [CBFileUtils deleteFile:fileFullPath];
    }
}

#pragma mark - Private Methods

-(void) _setupInstance
{
    _downloadQueue = [[SeedsDownloadQueue alloc] init];
    
    _seedDAO = [DAOFactory getSeedDAO];
}

-(TorrentDownloadAgent*) _getTorrentDownloadAgent:(Seed*) seed
{
    NSMutableString* downloadDirPath = [NSMutableString string];
    [downloadDirPath appendString:_downloadPath];
    [downloadDirPath appendString:@"/"];
    NSString* publishDateStr = seed.publishDate;
    [downloadDirPath appendString:publishDateStr];
    
    [CBFileUtils createDirectory:downloadDirPath];
    
    TorrentDownloadAgent* agent = [[TorrentDownloadAgent alloc] initWithSeed:seed downloadPath:downloadDirPath];
    return agent;
}

-(void) _downloadTorrentFile:(Seed*) seed
{
    TorrentDownloadAgent* agent = [self _getTorrentDownloadAgent:seed];
    [agent downloadWithDelegate:self];
}

-(void) _deleteTorrentFile:(Seed*) seed
{
    NSString* torrentFileFullPath = [TorrentDownloadAgent torrentFileFullPath:seed];
    [CBFileUtils deleteFile:torrentFileFullPath];
}

#pragma mark - TorrentDownloadAgentDelegate

-(void) torrentDownloadStarted:(Seed*) seed
{
    [_downloadQueue updateSeedStatus:seed status:SeedIsDownloading];
}

-(void) torrentDownloadFinished:(Seed*) seed
{
    
}

-(void) torrentDownloadFailed:(Seed*) seed error:(NSError*) error
{
    DLog(@"Seed(localId=%d) download failed with error:%@", seed.localId, error.localizedDescription);
    [_downloadQueue updateSeedStatus:seed status:SeedDownloadFailed];    
}

-(void) torrentSaveFinished:(Seed*) seed filePath:(NSString*) filePath
{
    DLog(@"Seed(localId=%d) save successfully.", seed.localId);
    [_downloadQueue updateSeedStatus:seed status:SeedDownloaded];
}

-(void) torrentSaveFailed:(Seed*) seed filePath:(NSString*) filePath
{
    DLog(@"Seed(localId=%d) save failed.", seed.localId);
    [_downloadQueue updateSeedStatus:seed status:SeedDownloadFailed];
}

@end
