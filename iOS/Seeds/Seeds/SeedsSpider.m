//
//  SeedsSpider.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsSpider.h"

#import "TorrentListDownloadAgent.h"

@interface SeedsSpider()
{
    SeedsVisitor* visitor;
    BOOL isPullOperationDone;
}

@end

@implementation SeedsSpider

@synthesize seedsSpiderDelegate = _seedsSpiderDelegate;
@synthesize torrentListDownloadAgentDelegate = _torrentListDownloadAgentDelegate;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        visitor = [[SeedsVisitor alloc] init];
        _torrentListDownloadAgentDelegate = self;
        isPullOperationDone = NO;
    }
    
    return self;
}

-(NSString*) pullSeedListLinkByDate:(NSDate *)date
{
    NSMutableString* link = [NSMutableString stringWithCapacity:0];
    
    date = (nil != date) ? date : [NSDate date];
    NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:date];

    NSMutableString* titleStr = [NSMutableString stringWithCapacity:0];
    [titleStr appendString:@"["];
    [titleStr appendString:dateStr];
    [titleStr appendString:@"]"];
    [titleStr appendString:@"最新BT合集"];

#warning http://stackoverflow.com/questions/9584663/datawithcontentsofurl-and-http-302-redirects
    NSError* error = nil;
    for (NSInteger pageNum = SEEDLIST_LINK_PAGENUM_START; pageNum <= SEEDLIST_LINK_PAGENUM_END; pageNum++)
    {
        DLog(@"Start to analyze channel list page number: %d", pageNum);
        NSMutableString* channelLink = [NSMutableString stringWithCapacity:0];
        [channelLink appendString:LINK_SEEDLIST_CHANNEL];
        [channelLink appendString:LINK_SEEDLIST_CHANNEL_PAGE];
        [channelLink appendString: [NSString stringWithFormat: @"%d", pageNum]];
        NSURL* channelUrl = [NSURL URLWithString:channelLink];
        NSData* data = [NSData dataWithContentsOfURL:channelUrl options:NSDataReadingMappedIfSafe error:&error];
        if (0 != error.code)
        {
            DLog(@"Access Link: %@ end error = %d", LINK_SEEDLIST_CHANNEL, [error code]);
            // TODO: Need feedback to UI
            return link;
        }

        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];
        NSMutableString* xql = [NSMutableString stringWithString:@"//a[text()="];
        [xql appendString:@"\""];
        [xql appendString:titleStr];
        [xql appendString:@"\"]"];
        DLog(@"xql = %@", xql);
        
        TFHppleElement* elemement = [doc peekAtSearchWithXPathQuery:xql];
        if (nil != elemement)
        {
            [link appendString:@"http://"];
            [link appendString:SEEDS_SERVER_IP];
            [link appendString:@"/"];
            [link appendString:[elemement objectForKey:@"href"]];

            break;
        }
    }
    
    return link;
}

-(NSArray*) pullSeedsFromLink:(NSString*) link
{
    NSMutableArray* seedList = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != link && 0 < link.length)
    {
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:link] options:NSDataReadingMappedIfSafe error:&error];
        if (0 != error.code)
        {
            DLog(@"Access Link: %@ end error = %d", link, [error code]);
            // TODO: Need feedback on UI
            return seedList;
        }
        
        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];

        NSString* xql = @"//text() | //a | //img";
        DLog(@"xql = %@", xql);
        
        NSArray* elements = [doc searchWithXPathQuery:xql];
        NSArray* seeds = [visitor visitNodes:elements];
        [seedList addObjectsFromArray:seeds];
    }
    
    return seedList;
}

// Should be processed in single background thread
-(void)pullSeedsInfo
{    
    // Step 10: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 在本地KV缓存中，检查时间标对应的数据同步状态：（a. 已同步；b. 未同步），如果是未同步状态，则继续下一步，反之停止操作
    // Step 30: 依次对前天、昨天、今天三个时间标进行Seeds发布页链接的抓取（搜索范围：主题列表页面的第1页至第10页）
    // Step 40: 对Seeds发布页面进行分析获取Seed List
    // Step 50: 删除数据库中原有相同时间标的所有记录
    // Step 60: 再将新数据保存入数据库（事务操作）
    // Step 70: 更新本地KV缓存中时间标的对应数据同步状态
    // Step 80: 删除数据库中原有的，处于这三天之前的，非收藏状态的所有记录

    // Step XX: 下载种子文件到Documents，并按时间标创建新文件夹

    // Step XX:
    NSMutableDictionary* torrentLinksByDateDic = [NSMutableDictionary dictionary];
    
    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderStarted:)])
    {
        [_seedsSpiderDelegate spiderStarted:NSLocalizedString(@"Preparing", nil)];
    }
    
//    [[UserDefaultsModule sharedInstance] resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY]; // for test only
    
    // Step 10:
    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
    {
        [_seedsSpiderDelegate spiderIsProcessing:NSLocalizedString(@"Stamps Computing", nil) minorStatus:nil];
    }
    
    id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
    NSArray* last3Days = [CBDateUtils lastThreeDays];
    for (NSDate* day in last3Days)
    {
        // Step 20:
        NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
        NSMutableString* hudStr1 = [NSMutableString stringWithCapacity:0];
        [hudStr1 appendString:dateStr];
        [hudStr1 appendString:STR_SPACE];
        [hudStr1 appendString:NSLocalizedString(@"Pulling", nil)];
        if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
        {
            [_seedsSpiderDelegate spiderIsProcessing:hudStr1 minorStatus:NSLocalizedString(@"Status Checking", nil)];
        }
        
        BOOL hasSyncBefore = [[UserDefaultsModule sharedInstance] isThisDaySync:day];
        DLog(@"Seeds in %@ have been synchronized yet? %@", dateStr, (hasSyncBefore) ? @"YES" : @"NO");
        if (!hasSyncBefore)
        {            
            // Step 30:
            if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
            {
                [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Link Analyzing", nil)];
            }
            
            NSString* channelLink = [self pullSeedListLinkByDate:day];
            if (nil != channelLink && 0 < channelLink.length)
            {
                // Step 40:
                if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                {
                    [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Parsing", nil)];
                }
                
                NSArray* seedList = [self pullSeedsFromLink:channelLink];
                [self fillCommonInfoToSeeds:seedList date:day];
                
                // Step 50:
                NSMutableString* hudStr2 = [NSMutableString stringWithCapacity:0];
                [hudStr2 appendString:dateStr];
                [hudStr2 appendString:STR_SPACE];
                [hudStr2 appendString:NSLocalizedString(@"Saving", nil)];
                if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                {
                    [_seedsSpiderDelegate spiderIsProcessing:hudStr2 minorStatus:NSLocalizedString(@"Seeds Clearing", nil)];
                }
                
                BOOL optSuccess = [seedDAO deleteSeedsByDate:day];
                if (optSuccess)
                {
                    // Step 60:
                    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                    {
                        [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Saving", nil)];
                    }
                    
                    optSuccess = [seedDAO insertSeeds:seedList];
                    if (!optSuccess)
                    {
                        DLog(@"Fail to save seed records into table with date: %@", dateStr);
                        
                        if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                        {
                            [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Saving", nil)];
                        }
                    }
                }
                else
                {
                    DLog(@"Fail to clear seed table with date: %@", dateStr);
                    
                    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                    {
                        [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Clearing", nil)];
                    }
                }
                
                // Step XX:
                [torrentLinksByDateDic setObject:seedList forKey:dateStr];
                
                // Step 70:
                if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                {
                    [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Status Saving", nil)];
                }
                
                BOOL hasSyncYet = optSuccess;
                [[UserDefaultsModule sharedInstance] setThisDaySync:day sync:hasSyncYet];
            }
            else
            {
                NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
                DLog(@"Seeds channel link can't be found with date: %@", dateStr);
                
                if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
                {
                    [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Analyzing", nil)];
                }
            }
        }
        else
        {
            DLog(@"Day: %@ has been sync before.", dateStr);
            
            if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
            {
                [_seedsSpiderDelegate spiderIsProcessing:nil minorStatus:NSLocalizedString(@"Pulled Yet", nil)];
            }
        }
    }
    
    // Step 80:
    DLog(@"Clean old and unfavorited seed records.");
    [seedDAO deleteAllSeedsExceptFavoritedOrLastThreeDayRecords:last3Days];
    
    NSInteger keyCount = torrentLinksByDateDic.allKeys.count;
    if (0 < keyCount)
    {
        // Step XX:
        __block BOOL directoryIsReady = NO;
        
        TorrentListDownloadAgent* downloadAgent = [[TorrentListDownloadAgent alloc] init];
        [torrentLinksByDateDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            // Create date folder if necessary
            NSString* dateStr = (NSString*)key;
            NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
            NSString* torrentsPath = [documentsPath stringByAppendingPathComponent:FOLDER_TORRENTS];
            
            NSFileManager* fm = [NSFileManager defaultManager];
            NSError* error = nil;
            if ([fm fileExistsAtPath:torrentsPath])
            {
                directoryIsReady = YES;
            }
            else
            {
                directoryIsReady = [fm createDirectoryAtPath:torrentsPath withIntermediateDirectories:NO attributes:nil error:&error];
            }
            
            if (directoryIsReady)
            {
                NSString* dateFolderPath = [torrentsPath stringByAppendingPathComponent:dateStr];
                if ([fm fileExistsAtPath:dateFolderPath])
                {
                    directoryIsReady = [fm removeItemAtPath:dateFolderPath error:&error];
                    if (!directoryIsReady)
                    {
                        DLog(@"Failed to remove folder: %@ with error: %@", dateFolderPath, [error description]);
                    }
                }
                
                directoryIsReady = [fm createDirectoryAtPath:dateFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
                if (directoryIsReady)
                {
                    // Download torrents with date
                    NSArray* seeds = (NSArray*)obj;
                    [downloadAgent addSeeds:seeds downloadPath:dateFolderPath];
                }
                else
                {
                    DLog(@"Failed to create folder: %@ with error: %@", dateFolderPath, error.localizedDescription);
                }
            }
            else
            {
                DLog(@"Failed to create folder: %@ with error: %@", torrentsPath, error.localizedDescription);
            }
        }];
        
        if (directoryIsReady)
        {
            [downloadAgent downloadWithDelegate:_torrentListDownloadAgentDelegate];
            
            while (!isPullOperationDone)
            {
                usleep(100);
            }
        }
        else
        {
            if ([_torrentListDownloadAgentDelegate respondsToSelector:@selector(torrentListDownloadFinished:)])
            {
                [_torrentListDownloadAgentDelegate torrentListDownloadFinished:NSLocalizedString(@"Folder Exception", nil)];
            }
        }
    }
    else
    {
        if ([_torrentListDownloadAgentDelegate respondsToSelector:@selector(torrentListDownloadFinished:)])
        {
            [_torrentListDownloadAgentDelegate torrentListDownloadFinished:NSLocalizedString(@"Sync Yet", nil)];
        }
    }

    
    sleep(2);
}

-(void) fillCommonInfoToSeeds:(NSArray*) seeds date:(NSDate*) day
{
    if (nil != seeds)
    {
        for (Seed* seed in seeds)
        {
            [seed setType:@"AV"];
            [seed setSource:@"咪咪爱"];
            NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STARDARD_DATE_FORMAT andDate:day];
            [seed setPublishDate:dateStr];
            [seed setFavorite:NO];
        }
    }
}

-(void) torrentListDownloadStarted:(NSString*) majorStatus
{
    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
    {
        [_seedsSpiderDelegate spiderIsProcessing:majorStatus minorStatus:nil];
    }
}

-(void) torrentListDownloadFinished:(NSString*) majorStatus
{
    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderFinished:)])
    {
        [_seedsSpiderDelegate spiderFinished:majorStatus];
    }
    
    isPullOperationDone = YES;
}

-(void) torrentListDownloadInProgress:(NSString*) majorStatus minorStatus:(NSString*) minorStatus
{
    if ([_seedsSpiderDelegate respondsToSelector:@selector(spiderIsProcessing:minorStatus:)])
    {
        [_seedsSpiderDelegate spiderIsProcessing:majorStatus minorStatus:minorStatus];
    }
}

@end
