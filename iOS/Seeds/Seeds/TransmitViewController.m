//
//  TransmitViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmitViewController.h"

#import "CBFileUtils.h"

#define _TRANS_CANCEL_FLAG_CHECK \
if (_cancelTransmission)\
{\
    [self updateConsole:NSLocalizedString(@"Transmission is cancel.", nil)];\
    return;\
}

@interface TransmitViewController ()
{
    NSMutableString* consoleInfo;
    
    UIBarButtonItem* _stopBarButton;
    
    BOOL _isTransmissionStarted;
    
    TransmissionModule* _transmitModule;
}

@end

@implementation TransmitViewController

@synthesize consoleView = _consoleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)awakeFromNib
{    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [self _setupViewController];    
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self _startTransmissionService];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self _stopTransmissionService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self _unregisterNotifications];
    
    [self setConsoleView:nil];
    [super viewDidUnload];
}

#pragma mark - Private Methods

- (void) _startTransmissionService
{
    if (!_isTransmissionStarted)
    {
        _isTransmissionStarted = YES;
        [self _clearConsole];
        [self performSelectorInBackground:@selector(_transmitTaskForUserMannuallyDownloads) withObject:nil];
    }
}

- (void) _stopTransmissionService
{
    if (_isTransmissionStarted)
    {
        [_transmitModule stopHTTPServer];
        
        _isTransmissionStarted = NO;
    }
}

- (void) _appDidEnterBackground
{
    [self _stopTransmissionService];
}

- (void) _appDidBecomeActive
{
    UIViewController* vc = self.presentedViewController;
    if (nil == vc)
    {
        [self _startTransmissionService];
    }
}

-(void) _onClickStopBarButton
{
    [self _stopTransmissionService];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) _setupViewController
{
    [self _setupView];
    
    [self _registerGestureRecognizers];
}

-(void) _setupView
{
    _transmitModule = [TransmissionModule sharedInstance];
    
    _isTransmissionStarted = NO;
    
    if (nil == _stopBarButton)
    {
        _stopBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Stop", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_onClickStopBarButton)];
    }
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self _registerNotifiations];
    
    [self _formatFlatUI];
}

- (void) _formatFlatUI
{
    _consoleView.textColor = COLOR_TEXT_INFO;
    _consoleView.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
}

- (void) _registerNotifiations
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) _unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) _registerGestureRecognizers
{    
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_consoleView addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeRight:(UISwipeGestureRecognizer*) gestureRecognizer
{
    [self _stopTransmissionService];
    
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) _transmitTaskForUserMannuallyDownloads
{
    // Step 10: 清理旧的zip包文件    
    // Step 20: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[2013-5-08]，[2013-5-07]，[2013-5-06]），进行zip打包
    // Step 30: 动态生成index.html页面，包含订阅源地址，前天、昨天、今天三个时间标对应的torrent文件zip包下载链接
    // Step 40: 启动HTTP服务器
    // Step 50: 更新HTTP服务器的地址和端口信息至UI
    
    BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
    if (!isWiFiEnabled)
    {
        [self _updateConsole:NSLocalizedString(@"Transmission module needs WiFi environment...", nil)];
        [self _showStopBarButton];
        return;
    }
    
    // Step 10:
    NSString* downloadPath = [SeedsDownloadAgent downloadPath];
    
    [self _updateConsole:NSLocalizedString(@"Clearning old files...", nil)];
    NSArray* oldZipFiles = [CBFileUtils filesInDirectory:downloadPath fileExtendName:FILE_EXTENDNAME_ZIP];
    for (NSString* oldZipFile in oldZipFiles)
    {
        [CBFileUtils deleteFile:oldZipFile];
    }
    
    // Step 20:
    UserDefaultsModule* _userDefaults = [UserDefaultsModule sharedInstance];
    NSArray* last3Days = [_userDefaults lastThreeDays];
    for (NSDate* day in last3Days)
    {
        NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];
        NSString* dayFolderPath = [downloadPath stringByAppendingPathComponent:dayStr];
        NSArray* files = [CBFileUtils filesInDirectory:dayFolderPath fileExtendName:FILE_EXTENDNAME_TORRENT];
        
        NSString* info = [NSString stringWithFormat:NSLocalizedString(@"[%@] %d torrent files are packaging...", nil), dayStr, files.count];
        [self _updateConsole:info];
        NSMutableString* zipName = [NSMutableString stringWithString:downloadPath];
        [zipName appendString:@"/"];
        [zipName appendString:dayStr];
        [zipName appendString:FILE_EXTENDNAME_DOT_ZIP];
        
        NSString* zipFileFullPath = [CBFileUtils newZipFileWithFiles:zipName zipFiles:files];
        DDLogVerbose(@"New zip file created:%@", zipFileFullPath);
    }
    
    // Step 30:
    [self _updateConsole:NSLocalizedString(@"Web page is generating...", nil)];
    BOOL flag = [_transmitModule generateHtmlPageWithLast3Days:last3Days];
    if (flag)
    {
        // Step 40:
        [self _updateConsole:NSLocalizedString(@"HTTP server is initializing...", nil)];
        flag = [_transmitModule startHTTPServer];
        if (flag)
        {
            [self _updateConsole:NSLocalizedString(@"HTTP server is starting...", nil)];
            
            // Step 50:
            NSString* name = [_transmitModule httpServerName];
            NSInteger port = [_transmitModule httpServerPort];
            
            if (nil != name && 0 < name.length)
            {
                NSMutableString* addrStr = [NSMutableString string];
                
                [addrStr appendString:@"http://"];
                [addrStr appendString:name];
                [addrStr appendString:@":"];
                [addrStr appendString:[NSString stringWithFormat:@"%d", port]];
                
                [addrStr insertString:NSLocalizedString(@"HTTP server address:", nil) atIndex:0];
                [self _updateConsole: addrStr];
            }
            else
            {
                [self _updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
            }
        }
        else
        {
            [self _updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
        }
    }
    else
    {
        [self _updateConsole:NSLocalizedString(@"Web page generation is fail.", nil)];
    }
    
    [self _showStopBarButton];
}

- (void) _showStopBarButton
{
    CONSOLE_LINEINFO_DISPLAY_DELAY
    
    [self.navigationItem setHidesBackButton:NO];
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Stop", nil);
    self.navigationItem.leftBarButtonItems = @[_stopBarButton];
}

- (void) _transmitTaskForAppAutoAllDownloads
{
    // Step 10: 根据当日时间（例如5月8日）获取今天、昨天、前天三个时间标（例如[5-08]，[5-07]，[5-06]）
    // Step 20: 清理旧文件
    // Step 30: 依次对前天、昨天、今天三个时间标对应的目录进行torrent文件扫描和打包
    // Step 40: 动态生成index.html页面，包含前天、昨天、今天三个时间标对应的torrent文件zip包下载链接
    // Step 50: 启动HTTP服务器
    // Step 60: 更新HTTP服务器的地址和端口信息至UI
    
    BOOL isWiFiEnabled = [CBNetworkUtils isWiFiEnabled];
    if (!isWiFiEnabled)
    {
        [self _updateConsole:NSLocalizedString(@"Transmission module needs WiFi environment...", nil)];
        [self _showStopBarButton];
        return;
    }
    
    // Step 10:
    [self _updateConsole:NSLocalizedString(@"Torrent files are preparing...", nil)];
    
    UserDefaultsModule* _userDefaults = [UserDefaultsModule sharedInstance];
    NSArray* last3Days = [_userDefaults lastThreeDays];
    
    NSString* torrentsPath = [SeedsDownloadAgent downloadPath];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL flag = NO;
    NSError* error = nil;
    if (![fm fileExistsAtPath:torrentsPath])
    {
        flag = [fm createDirectoryAtPath:torrentsPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!flag)
        {
            DDLogError(@"Failed to create directory at path:%@", torrentsPath);
            [self _updateConsole:NSLocalizedString(@"Torrents directory failed to create.", nil)];
            return;
        }
    }
    
    for (NSDate* day in last3Days)
    {
        NSString* dayStr = [CBDateUtils shortDateString:day];
        NSString* dayFolderPath = [torrentsPath stringByAppendingPathComponent:dayStr];
        NSArray* files = [CBFileUtils filesInDirectory:dayFolderPath fileExtendName:FILE_EXTENDNAME_TORRENT];
        
        // Step 20:
        
        // Step 30:
        [self _updateConsole:NSLocalizedString(@"Torrent files are packaging...", nil)];
        NSMutableString* zipName = [NSMutableString stringWithString:dayStr];
        [zipName appendString:FILE_EXTENDNAME_DOT_ZIP];
        NSString* zipFilePath = [torrentsPath stringByAppendingPathComponent:zipName];
        zipFilePath = [CBFileUtils newZipFileWithFiles:zipFilePath zipFiles:files];
        DDLogVerbose(@"New zip file created:%@", zipFilePath);
    }
    
    // Step 40:
    [self _updateConsole:NSLocalizedString(@"Web page is generating...", nil)];
    flag = [_transmitModule generateHtmlPageWithLast3Days:last3Days];
    if (flag)
    {
        // Step 50:
        [self _updateConsole:NSLocalizedString(@"HTTP server is initializing...", nil)];
        flag = [_transmitModule startHTTPServer];
        if (flag)
        {
            [self _updateConsole:NSLocalizedString(@"HTTP server is starting...", nil)];
        }
        else
        {
            [self _updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
        }
        // Step 60:
        NSString* name = [_transmitModule httpServerName];
        NSInteger port = [_transmitModule httpServerPort];
        
        if (nil != name && 0 < name.length)
        {
            NSMutableString* addrStr = [NSMutableString string];
            
            [addrStr appendString:@"http://"];
            [addrStr appendString:name];
            [addrStr appendString:@":"];
            [addrStr appendString:[NSString stringWithFormat:@"%d", port]];
            
            [addrStr insertString:NSLocalizedString(@"HTTP server address:", nil) atIndex:0];
            
            [self _updateConsole: addrStr];
        }
        else
        {
            [self _updateConsole:NSLocalizedString(@"HTTP server failed to start.", nil)];
        }
        
    }
    else
    {
        [self _updateConsole:NSLocalizedString(@"Web page generation is fail.", nil)];
    }
}

- (void) _updateConsole:(NSString*) info
{
    dispatch_async(dispatch_get_main_queue(), ^(){
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
            
            [_consoleView setText:consoleInfo];
            CONSOLE_LINEINFO_DISPLAY_DELAY
        }
    });
}

- (void) _clearConsole
{
    consoleInfo = [NSMutableString string];
    [self _updateConsole:NSLocalizedString(@"Transmission module is initializing...", nil)];
}

@end
