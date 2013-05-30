//
//  TransmitViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmitViewController.h"

#import "CBFileUtils.h"

@interface TransmitViewController ()
{
    NSMutableString* consoleInfo;
}

@end

@implementation TransmitViewController

@synthesize consoleView = _consoleView;

- (void) transmitTask
{
    // Step 10: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 在本地KV缓存中，检查时间标对应的torrent文件打包状态：（a. 已打包；b. 未打包），如果是未打包状态，则继续下一步，反之停止操作
    // Step 30: 依次对前天、昨天、今天三个时间标对应的目录进行torrent文件扫描和打包
    // Step 40: 动态生成index.html页面，包含前天、昨天、今天三个时间标对应的torrent文件zip包下载链接
    // Step 50: 启动HTTP服务器
    // Step 60: 更新HTTP服务器的地址和端口信息至UI

    TransmissionModule* transmitModule = [TransmissionModule sharedInstance];    
    
    // Step 10:
    [self updateConsole:NSLocalizedString(@"Torrent files are preparing...", nil)];
    
    NSArray* last3Days = [CBDateUtils lastThreeDays];
    NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
    NSString* torrentsPath = [documentsPath stringByAppendingPathComponent:FOLDER_TORRENTS];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL flag = NO;
    NSError* error = nil;
    if (![fm fileExistsAtPath:torrentsPath])
    {
        flag = [fm createDirectoryAtPath:torrentsPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for (NSDate* day in last3Days)
    {
        NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
        NSString* dayFolderPath = [torrentsPath stringByAppendingPathComponent:dayStr];
        NSArray* files = [CBFileUtils filesInDirectory:dayFolderPath fileExtendName:@"torrent"];
        
        // Step 20:
        
        // Step 30:
        [self updateConsole:NSLocalizedString(@"Torrent files are packaging...", nil)];
        NSMutableString* zipName = [NSMutableString stringWithString:dayStr];
        [zipName appendString:FILE_EXTENDNAME_DOT_ZIP];
        NSString* zipFilePath = [torrentsPath stringByAppendingPathComponent:zipName];
        zipFilePath = [CBFileUtils newZipFileWithFiles:zipFilePath zipFiles:files];
        DLog(@"New zip file created:%@", zipFilePath);
    }
    
    // Step 40:
    [self updateConsole:NSLocalizedString(@"Web page is generating...", nil)];
    flag = [transmitModule generateHtmlPage:last3Days];
    if (flag)
    {
        // Step 50:
        [self updateConsole:NSLocalizedString(@"HTTP server is initializing...", nil)];
        flag = [transmitModule startHTTPServer];
        if (flag)
        {
            [self updateConsole:NSLocalizedString(@"HTTP server started...", nil)];
        }
        else
        {
            [self updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
        }
        // Step 60:
        NSString* name = [transmitModule httpServerName];
        NSInteger port = [transmitModule httpServerPort];
        
        if (nil != name && 0 < name.length)
        {
            NSMutableString* addrStr = [NSMutableString string];
            
            [addrStr appendString:@"http://"];
            [addrStr appendString:name];
            [addrStr appendString:@":"];
            [addrStr appendString:[NSString stringWithFormat:@"%d", port]];
         
            [addrStr insertString:NSLocalizedString(@"HTTP server address:", nil) atIndex:0];
            
            [self updateConsole: addrStr];
        }
        else
        {
            [self updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
        }
        
    }
    else
    {
        [self updateConsole:NSLocalizedString(@"Web page generation is fail.", nil)];
    }
    
}

- (void) updateConsole:(NSString*) info
{
    if (nil == consoleInfo)
    {
        consoleInfo = [NSMutableString string];
        
        NSString* originText = _consoleView.text;
        if (nil != originText && 0 < originText.length)
        {
            [consoleInfo appendString:originText];
            [consoleInfo appendString:@"\n"];
        }
    }

    if (nil != info && 0 < info.length)
    {
        [consoleInfo appendString:info];
        [consoleInfo appendString:@"\n"];

        dispatch_sync(dispatch_get_main_queue(), ^(){
            [_consoleView setText:consoleInfo];
            sleep(1);
        });
    }
}

- (void) clearConsole
{
    [_consoleView setText:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_consoleView setText:NSLocalizedString(@"Transmission module is initializing...", nil)];
    
    [self performSelectorInBackground:@selector(transmitTask) withObject:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TransmissionModule* transmitModule = [TransmissionModule sharedInstance];
    [transmitModule stopHTTPServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setConsoleView:nil];
    [super viewDidUnload];
}
@end
