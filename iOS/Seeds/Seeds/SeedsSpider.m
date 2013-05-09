//
//  SeedsSpider.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsSpider.h"

#define SEEDS_SERVER_IP @"174.123.15.31"
#define LINK_SEEDLIST_CHANNEL_PAGE @"&page="
#define LINK_SEEDLIST_CHANNEL @"http://"SEEDS_SERVER_IP"/forumdisplay.php?fid=55"
#define LINK_SEEDLIST @"http://"SEEDS_SERVER_IP"/viewthread.php?tid=931724&extra=page%3D1"

#define SEEDLIST_LINK_PAGENUM_START 1
#define SEEDLIST_LINK_PAGENUM_END 10

#define DATE_HOLDER @"$DATE$"
#define SEEDLIST_LINK_TITLE @"["DATE_HOLDER"]BT合集"

#define HUD_DISPLAY_1S sleep(1)

@interface SeedsSpider()
{
    SeedsVisitor* visitor;
}

@end

@implementation SeedsSpider

-(id) init
{
    self = [super init];
    
    if (self)
    {
        visitor = [[SeedsVisitor alloc] init];
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
-(void)pullSeedsInfo:(MBProgressHUD*) HUD
{    
    // Step 1: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 2: 在本地KV缓存中，检查时间标对应的数据同步状态：（a. 已同步；b. 未同步），如果是未同步状态，则继续下一步，反之停止操作
    // Step 3: 依次对前天、昨天、今天三个时间标进行Seeds发布页链接的抓取（搜索范围：主题列表页面的第1页至第10页）
    // Step 4: 对Seeds发布页面进行分析获取Seed List
    // Step 5: 删除数据库中原有相同时间标的所有记录
    // Step 6: 再将新数据保存入数据库（事务操作）
    // Step 7: 更新本地KV缓存中时间标的对应数据同步状态
    
	HUD.labelText = @"Pulling";
    HUD.minSize = CGSizeMake(135.f, 135.f);
    HUD_DISPLAY_1S;
    
    // Step 1:
    HUD.detailsLabelText = @"Stamps Computing";
    HUD_DISPLAY_1S;
    
    NSArray* last3Days = [CBDateUtils lastThreeDays];
    for (NSDate* day in last3Days)
    {
        NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
        
        // Step 2:
        HUD.detailsLabelText = @"Status Checking";
        HUD_DISPLAY_1S;
        
        BOOL hasSyncBefore = [[UserDefaultsModule sharedInstance] isThisDaySync:day];
        DLog(@"Seeds in %@ have been synchronized yet? %@", dateStr, (hasSyncBefore) ? @"YES" : @"NO");
        if (!hasSyncBefore)
        {
            // Step 3:
            HUD.detailsLabelText = @"Link Analyzing";
            HUD_DISPLAY_1S;
            
            NSString* channelLink = [self pullSeedListLinkByDate:day];
            if (nil != channelLink && 0 < channelLink.length)
            {
                // Step 4:
                HUD.detailsLabelText = @"Seeds Pulling";
                HUD_DISPLAY_1S;
                
                NSArray* seedList = [self pullSeedsFromLink:channelLink];
                [self fillCommonInfoToSeeds:seedList date:day];
                
                // Step 5:
                HUD.labelText = @"Saving";
                HUD.detailsLabelText = @"Seeds Clearing";
                HUD_DISPLAY_1S;
            
                id<SeedDAO> seedDAO = [DAOFactory getSeedDAO];
                BOOL optSuccess = [seedDAO deleteSeedsByDate:dateStr];
                if (optSuccess)
                {
                    // Step 6:
                    HUD.detailsLabelText = @"Seeds Saving";
                    HUD_DISPLAY_1S;
                    
                    optSuccess = [seedDAO insertSeeds:seedList];
                    if (!optSuccess)
                    {
                        DLog(@"Fail to save seed records into table with date: %@", dateStr);
                        
                        HUD.detailsLabelText = @"Fail Saving";
                        HUD_DISPLAY_1S;
                    }
                }
                else
                {
                    DLog(@"Fail to clear seed table with date: %@", dateStr);
                    
                    HUD.detailsLabelText = @"Fail Clearing";
                    HUD_DISPLAY_1S;
                }
                
                // Step 7:
                HUD.detailsLabelText = @"Status Saving";
                HUD_DISPLAY_1S;
                
                BOOL hasSyncYet = optSuccess;
                [[UserDefaultsModule sharedInstance] setThisDaySync:day sync:hasSyncYet];
            }
            else
            {
                NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
                DLog(@"Seeds channel link can't be found with date: %@", dateStr);
                
                HUD.detailsLabelText = @"Fail Analyzing";
                HUD_DISPLAY_1S;
            }
        }
        else
        {
            DLog(@"Day: %@ has been sync before.", dateStr);
            
            HUD.detailsLabelText = @"Pulled Yet";
            HUD_DISPLAY_1S;
        }
    }
    
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Completed";
    HUD.detailsLabelText = nil;
    HUD_DISPLAY_1S;
}

-(void) fillCommonInfoToSeeds:(NSArray*) seeds date:(NSDate*) day
{
    if (nil != seeds)
    {
        for (Seed* seed in seeds)
        {
            [seed setType:@"AV"];
            NSString* dateStr = [CBDateUtils dateStringInLocalTimeZoneWithStandardFormat:day];
            [seed setPublishDate:dateStr];
            [seed setFavorite:NO];
        }
    }
}

@end
