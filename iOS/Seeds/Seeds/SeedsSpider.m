//
//  SeedsSpider.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsSpider.h"

#import "SeedsDownloadAgent.h"

#import "SDWebImagePrefetcher.h"

#import "CBFileUtils.h"

@interface SeedsSpider()
{
    SeedsVisitor* _visitor;
    BOOL _isPullOperationDone;
    
    SeedsDownloadAgent* _downloadAgent;
    SeedPictureAgent* _pictureAgent;
    
    GUIModule* _guiModule;
    
    NSMutableData* _receivedData;
    NSCondition* _lock;
    NSURLConnection* _urlConnection;
}

@end

@implementation SeedsSpider 

@synthesize seedsSpiderDelegate = _seedsSpiderDelegate;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        [self _setupInstance];
    }
    
    return self;
}

-(NSString*) pullSeedListLinkByDate:(NSDate *)date error:(__autoreleasing NSError**)errorPtr
{
    NSMutableString* link = [NSMutableString stringWithCapacity:0];
    
    date = (nil != date) ? date : [NSDate date];
    NSString* dateStr = [CBDateUtils shortDateString:date];

    NSMutableString* titleStr = [NSMutableString stringWithCapacity:0];
    [titleStr appendString:@"["];
    [titleStr appendString:dateStr];
    [titleStr appendString:@"]"];
    [titleStr appendString:@"最新BT合集"];

    NSError* error = nil;
    for (NSInteger pageNum = SEEDLIST_LINK_PAGENUM_START; pageNum <= SEEDLIST_LINK_PAGENUM_END; pageNum++)
    {
        DDLogInfo(@"Start to analyze channel list page number: %d", pageNum);
        NSMutableString* channelLink = [NSMutableString stringWithCapacity:0];
        [channelLink appendString:LINK_SEEDLIST_CHANNEL];
        [channelLink appendString:LINK_SEEDLIST_CHANNEL_PAGE];
        [channelLink appendString: [NSString stringWithFormat: @"%d", pageNum]];
        NSURL* channelUrl = [NSURL URLWithString:channelLink];
//        NSData* data = [NSData dataWithContentsOfURL:channelUrl options:NSDataReadingMappedIfSafe error:&error];
//        if (0 != error.code)
//        {
//            *errorPtr = error;
//            DDLogError(@"Access Link: %@ end error = %d", LINK_SEEDLIST_CHANNEL, [error code]);
//            return link;
//        }
        NSData* data = [self _readHtmlPageFromInternet:channelUrl error:&error];
        if (0 != error.code)
        {
            DDLogError(@"Access Link: %@ end error = %d", LINK_SEEDLIST_CHANNEL, [error code]);
            *errorPtr = error;
            return link;
        }
        
        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];
        NSMutableString* xql = [NSMutableString stringWithString:@"//a[text()="];
        [xql appendString:@"\""];
        [xql appendString:titleStr];
        [xql appendString:@"\"]"];
        DDLogVerbose(@"xql = %@", xql);
        
        TFHppleElement* elemement = [doc peekAtSearchWithXPathQuery:xql];
        if (nil != elemement)
        {
            [link appendString:@"http://"];
            [link appendString:SEEDS_RESOURCE_IP];
            [link appendString:@"/"];
            [link appendString:[elemement objectForKey:@"href"]];

            break;
        }
    }
    
    return link;
}

-(NSArray*) pullSeedsFromLink:(NSString*) link error:(__autoreleasing NSError**)errorPtr
{
    NSMutableArray* seedList = [NSMutableArray arrayWithCapacity:0];
    
    if (nil != link && 0 < link.length)
    {
//        NSError* __autoreleasing error = nil;
//        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:link] options:NSDataReadingMappedIfSafe error:&error];
//        if (0 != error.code)
//        {
//            DDLogError(@"Access Link: %@ end error = %d", link, [error code]);
//            *errorPtr = error;            
//            return seedList;
//        }
        NSURL* url = [NSURL URLWithString:link];
        NSError* error = nil;
        NSData* data = [self _readHtmlPageFromInternet:url error:&error];
        if (0 != error.code)
        {
            DDLogError(@"Access Link: %@ end error = %d", link, [error code]);
            *errorPtr = error;
            return seedList;
        }
        
        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];

        NSString* xql = @"//text() | //a | //img";
        DDLogVerbose(@"xql = %@", xql);
        
        NSArray* elements = [doc searchWithXPathQuery:xql];
        NSArray* seeds = [_visitor visitNodes:elements];
        [seedList addObjectsFromArray:seeds];
    }
    
    return seedList;
}

// Should be processed in single background thread
-(void) pullSeedsInfo:(NSArray*) days
{
    // Step 10: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 在本地KV缓存中，检查时间标对应的数据同步状态：（a. 已同步；b. 未同步），如果是未同步状态，则继续下一步，反之停止操作
    // Step 30: 依次对前天、昨天、今天三个时间标进行Seeds发布页链接的抓取（搜索范围：主题列表页面的第1页至第10页）
    // Step 40: 对Seeds发布页面进行分析获取Seed List
    // Step 50: 删除数据库中原有相同时间标的所有记录
    // Step 60: 再将新数据保存入数据库（事务操作）
    // Step 70: 更新本地KV缓存中时间标的对应数据同步状态
    // Step 80: 删除数据库中原有的，处于这三天之前的所有非收藏状态的记录
    // Step 90: 删除下载目录中原有的，处于这三天之前的的所有文件
    // Step 100: 删除缓存中所有过期的图片
    
    @try
    {
        BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
        BOOL is3GEnabled = [CBNetworkUtils is3GEnabled];
        if (!isWiFiEnabled && !is3GEnabled)
        {
            DDLogWarn(@"No internect connection");
            if (_seedsSpiderDelegate)
            {
                [_seedsSpiderDelegate taskCanceld:NSLocalizedString(@"Internet Disconnected", nil) minorStatus:nil];
            }
            return;
        }
        
        [_guiModule setNetworkActivityIndicatorVisible:YES];
        
        if (_seedsSpiderDelegate)
        {
            [_seedsSpiderDelegate taskStarted:NSLocalizedString(@"Preparing", nil) minorStatus:nil];
        }
        
        //    [[UserDefaultsModule sharedInstance] resetDefaultsInPersistentDomain:PERSISTENTDOMAIN_SYNCSTATUSBYDAY]; // for test only
        
        // Step 10:
        
        NSMutableArray* pulledSeedList = [NSMutableArray array];
        
        NSInteger hasAllSyncBefore = days.count;
        id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
        NSInteger dayIndex = TheDayBefore;
        for (NSDate* day in days)
        {
            // Step 20:
            NSString* dateStr = [CBDateUtils shortDateString:day];
            NSMutableString* hudStr1 = [NSMutableString stringWithCapacity:0];
            [hudStr1 appendString:dateStr];
            [hudStr1 appendString:STR_SPACE];
            [hudStr1 appendString:NSLocalizedString(@"Pulling", nil)];
            if (_seedsSpiderDelegate)
            {
                [_seedsSpiderDelegate taskIsProcessing:hudStr1 minorStatus:NSLocalizedString(@"Status Checking", nil)];
            }
            
            BOOL isDaySyncBefore = [[UserDefaultsModule sharedInstance] isThisDaySync:day];
            BOOL isDaySyncAfter = NO;
            DDLogVerbose(@"Seeds in %@ have been synchronized yet? %@", dateStr, (isDaySyncBefore) ? @"YES" : @"NO");
            if (!isDaySyncBefore)
            {
                // Step 30:
                if (_seedsSpiderDelegate)
                {
                    [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Link Analyzing", nil)];
                }
                
                NSError* error = nil;
                NSString* channelLink = [self pullSeedListLinkByDate:day error:&error];
                if (0 != error.code)
                {
                    DDLogError(@"Fail to pull seed list link by date: %@ with error: %@", day, error);
                    if (_seedsSpiderDelegate)
                    {
                        [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Analyzing", nil)];
                    }
                    
                    continue;
                }
                
                if (nil != channelLink && 0 < channelLink.length)
                {
                    // Step 40:
                    if (_seedsSpiderDelegate)
                    {
                        [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Parsing", nil)];
                    }
                    
                    error = nil;
                    NSArray* seedList = [self pullSeedsFromLink:channelLink error:&error];
                    if (0 != error.code)
                    {
                        DDLogError(@"Fail to pull seeds from link: %@ with error: %@", channelLink, error);
                        if (_seedsSpiderDelegate)
                        {
                            [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Parsing", nil)];
                        }
                        
                        continue;
                    }
                    else
                    {
                        [self fillCommonInfoToSeeds:seedList date:day];
                        
                        [pulledSeedList addObjectsFromArray:seedList];
                        
                        if (_seedsSpiderDelegate)
                        {
                            [_seedsSpiderDelegate taskDataUpdated:[NSString stringWithFormat:@"%d", dayIndex] data:[NSString stringWithFormat:@"%d", seedList.count]];
                        }
                    }
                    
                    // Step 50:
                    NSMutableString* hudStr2 = [NSMutableString stringWithCapacity:0];
                    [hudStr2 appendString:dateStr];
                    [hudStr2 appendString:STR_SPACE];
                    [hudStr2 appendString:NSLocalizedString(@"Saving", nil)];
                    if (_seedsSpiderDelegate)
                    {
                        [_seedsSpiderDelegate taskIsProcessing:hudStr2 minorStatus:NSLocalizedString(@"Seeds Organizing", nil)];
                    }
                    
                    BOOL optSuccess = [seedDAO deleteSeedsByDate:day];
                    if (optSuccess)
                    {
                        // Step 60:
                        if (_seedsSpiderDelegate)
                        {
                            [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Seeds Saving", nil)];
                        }
                        
                        optSuccess = [seedDAO insertSeeds:seedList];
                        if (!optSuccess)
                        {
                            DDLogError(@"Fail to save seed records into table with date: %@", dateStr);
                            if (_seedsSpiderDelegate)
                            {
                                [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Saving", nil)];
                            }
                        }
                    }
                    else
                    {
                        DDLogError(@"Fail to clear seed table with date: %@", dateStr);
                        if (_seedsSpiderDelegate)
                        {
                            [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Fail Clearing", nil)];
                        }
                    }
                    
                    // Step 70:
                    if (_seedsSpiderDelegate)
                    {
                        [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Status Saving", nil)];
                    }
                    
                    isDaySyncAfter = optSuccess;
                }
                else
                {
                    DDLogWarn(@"Seeds channel link can't be found with date: %@", dateStr);
                    if (nil != _seedsSpiderDelegate)
                    {
                        [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"No Update", nil)];
                        
                        if (_seedsSpiderDelegate)
                        {
                            [_seedsSpiderDelegate taskDataUpdated:[NSString stringWithFormat:@"%d", dayIndex] data:[NSString stringWithFormat:@"%d", 0]];
                        }
                    }
                    
                    isDaySyncAfter = YES;
                }
                
                [[UserDefaultsModule sharedInstance] setThisDaySync:day sync:isDaySyncAfter];
                
                hasAllSyncBefore--;
            }
            else
            {
                DDLogVerbose(@"Day: %@ has been sync before.", dateStr);
                
                if (_seedsSpiderDelegate)
                {
                    [_seedsSpiderDelegate taskIsProcessing:nil minorStatus:NSLocalizedString(@"Pulled Yet", nil)];
                }
            }
            
            dayIndex++;
        }
        
        if (hasAllSyncBefore == days.count)
        {
            if (_seedsSpiderDelegate)
            {
                [_seedsSpiderDelegate taskFinished:NSLocalizedString(@"Completed", nil) minorStatus:nil];
            }
        }
        else
        {
            // Step 80:
            DDLogVerbose(@"Clean old and unfavorited seed records.");
            [seedDAO deleteAllExceptLastThreeDaySeeds:days];
            if (_seedsSpiderDelegate)
            {
                [_seedsSpiderDelegate taskIsProcessing:NSLocalizedString(@"Seeds Organizing", nil) minorStatus:nil];
            }
            
            // Step 90:
            DDLogVerbose(@"Clean all old torrents before the last 3 days.");
            [_downloadAgent clearDownloadDirectory:days];
            
            if (_seedsSpiderDelegate)
            {
                [_seedsSpiderDelegate taskFinished:NSLocalizedString(@"Completed", nil) minorStatus:nil];
            }
        }
        
        [_guiModule setNetworkActivityIndicatorVisible:NO];
    }
    @catch (NSException* exception)
    {
        DDLogError(@"Caught an exception: %@", exception.debugDescription);
        
        if (_seedsSpiderDelegate)
        {
            [_seedsSpiderDelegate taskFailed:NSLocalizedString(@"Exception Caught", nil) minorStatus:nil];
        }
    }
    @finally
    {
        // Step 100:
        DDLogVerbose(@"Clean all expired image cache in disk.");
        [_pictureAgent cleanExpiredCache];
    }
}

-(void) fillCommonInfoToSeeds:(NSArray*) seeds date:(NSDate*) day
{
    if (nil != seeds)
    {
        for (Seed* seed in seeds)
        {
            [seed setType:SEED_TYPE_AV];
            [seed setSource:SEED_SOURCE_MM];
            NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
            [seed setPublishDate:dateStr];
            [seed setFavorite:NO];
        }
    }
}

-(void) _setupInstance
{
    _visitor = [[SeedsVisitor alloc] init];
    _isPullOperationDone = NO;
    
    CommunicationModule* _commModule = [CommunicationModule sharedInstance];
    _downloadAgent = _commModule.serverAgent.downloadAgent;
    _pictureAgent = _commModule.serverAgent.pictureAgent;
    
    _guiModule = [GUIModule sharedInstance];
    
    _receivedData = [[NSMutableData alloc] initWithData:nil];
    _lock = [[NSCondition alloc] init];
}

-(NSData*) _readHtmlPageFromInternet:(NSURL*) url error:(NSError**)errorPtr
{
    [_receivedData setLength:0];
    
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:TIMEOUT_LINKPARSE];
    [req setHTTPMethod: @"GET"];
    
    __block NSError* blockError = nil;
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (nil != data)
        {
            [_receivedData appendData:data];
        }
        
        if (nil != error)
        {
            blockError = error;
        }
        
        [_lock lock];
        [_lock signal];
        [_lock unlock];
    }];
    
    [_lock lock];
    [_lock wait];
    [_lock unlock];
    
    *errorPtr = blockError;    
    
    return _receivedData;
}

@end
