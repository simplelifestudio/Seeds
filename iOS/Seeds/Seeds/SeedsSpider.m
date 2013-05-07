//
//  SeedsSpider.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsSpider.h"

#define SEEDS_SERVER_IP @"174.123.15.31"
#define LINK_SEEDLIST_CHANNEL @"http://"SEEDS_SERVER_IP"/forumdisplay.php?fid=55&page=1"
#define LINK_SEEDLIST @"http://"SEEDS_SERVER_IP"/viewthread.php?tid=931724&extra=page%3D1"

#define SEEDLIST_LINK_DATE_FORMAT @"M-dd"

#define DATE_HOLDER @"$DATE$"
#define SEEDLIST_LINK_TITLE @"["DATE_HOLDER"]BT合集"

#define ATTR_NAME @"影片名稱"
#define ATTR_FORMAT @"文件類型"
#define ATTR_SIZE @"影片大小"
#define ATTR_MOSAIC @"有碼無碼"
#define ATTR_TORRENTLINK @"Link URL:"

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

    NSError* error = nil;
#warning http://stackoverflow.com/questions/9584663/datawithcontentsofurl-and-http-302-redirects
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:LINK_SEEDLIST_CHANNEL] options:NSDataReadingMappedIfSafe error:&error];
    DLog(@"Access Link: %@ end error = %d", LINK_SEEDLIST_CHANNEL, [error code]);
    
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
        DLog(@"Access Link: %@ end error = %d", link, [error code]);
        
        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];

        NSString* xql = @"//text()";
        DLog(@"xql = %@", xql);
        
        NSArray* elements = [doc searchWithXPathQuery:xql];
        NSArray* seeds = [visitor seedsFromTFHppleElements:elements];
        [seedList addObjectsFromArray:seeds];
    }
    
    return seedList;
}


-(void)pullSeedsInfo
{
    NSDate* today = [NSDate date];
    NSString* channelLink = [self pullSeedListLinkByDate:today];
    NSArray* seedList = [self pullSeedsFromLink:channelLink];
}

@end
