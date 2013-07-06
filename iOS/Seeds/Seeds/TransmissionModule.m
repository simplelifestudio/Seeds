//
//  TransmitModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmissionModule.h"

#import "HTTPServer.h"
#import "CBFileUtils.h"

@interface TransmissionModule()
{
    HTTPServer* httpServer;
    NSString* htmlCode;
}

@end

@implementation TransmissionModule

SINGLETON(TransmissionModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Transmission Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Transmission Module Thread", nil)];
    [self setKeepAlive:FALSE];

	httpServer = [[HTTPServer alloc] init];
}

-(void) releaseModule
{
    [self stopHTTPServer];
    
    [super releaseModule];
}

-(void) startService
{
    DLog(@"Module:%@ is started.", self.moduleIdentity);
    
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];

	[httpServer setName:HTTP_SERVER_NAME];
    [httpServer setPort:HTTP_SERVER_PORT];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	// [httpServer setPort:12345];
	
	// Serve files from our embedded Web folder
    NSString* webPath = [SeedsDownloadAgent downloadPath];
	DLog(@"HTTP server document root: %@", webPath);
	[httpServer setDocumentRoot:webPath];
    
    [super startService];
}

-(void) processService
{
    [self generateDownloadRootDirectory];
    
    MODULE_DELAY
}

- (BOOL)startHTTPServer
{
    BOOL flag = NO;
    
	NSError *error;
	if([httpServer start:&error])
	{
        flag = YES;
		DLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		DLog(@"Error starting HTTP Server: %@", error);
	}
    
    return flag;
}

-(void)stopHTTPServer
{
    if ([httpServer isRunning])
    {
        [httpServer stop];          
    }
}

-(NSInteger) httpServerPort
{
    NSInteger port = -1;
    
    if (nil != httpServer)
    {
        port = [httpServer listeningPort];
    }
    
    return port;
}

-(NSString*) httpServerName
{
    NSString* name = nil;
    
    if (nil != httpServer)
    {
        name = [CBNetworkUtils hostNameInWiFi];
    }
    
    return name;
}

-(BOOL)generateHtmlPageWithZipFileName:(NSString*) zipFileName
{
    BOOL flag = NO;
    
    if (nil != zipFileName && 0 < zipFileName)
    {
        int encodingMode = NSUTF8StringEncoding;
        
        if (nil == htmlCode)
        {
            NSString* htmlFilePath = [[NSBundle mainBundle] pathForResource:FILE_NAME_INDEX ofType:FILE_EXTENDNAME_HTML];
            NSData* data = [CBFileUtils dataFromFile:htmlFilePath];
            htmlCode = [[NSString alloc] initWithData:data encoding:encodingMode];
        }
        
        NSMutableString* htmlCodeCopy = [NSMutableString stringWithString:htmlCode];
        NSString* strAfterLinkReplaced = [CBStringUtils replaceSubString:zipFileName oldSubString:@"$LINK$" string:htmlCodeCopy];
        
        NSData* data = [strAfterLinkReplaced dataUsingEncoding: encodingMode];
        
        NSString* torrentsPath = [SeedsDownloadAgent downloadPath];
        NSString* indexHtmlFilePath = [torrentsPath stringByAppendingPathComponent:URL_INDEXPAGE];
        
        flag = [CBFileUtils dataToFile:data filePath:indexHtmlFilePath];
        if (!flag)
        {
            DLog(@"Failed to generate index.html file.");
        }
    }
    
    return flag;
}

-(BOOL)generateHtmlPageWithLast3Days:(NSArray*) last3Days;
{
    NSAssert(nil != last3Days, @"Date array is nil.");
    
    BOOL flag = NO;
    
    int encodingMode = NSUTF8StringEncoding;
    
    if (nil == htmlCode)
    {
        NSString* htmlFilePath = [[NSBundle mainBundle] pathForResource:FILE_NAME_INDEX ofType:FILE_EXTENDNAME_HTML];
        NSData* data = [CBFileUtils dataFromFile:htmlFilePath];
        htmlCode = [[NSString alloc] initWithData:data encoding:encodingMode];
    }
    
    NSMutableString* htmlCodeCopy = [NSMutableString stringWithString:htmlCode];
    NSInteger dayIndex = TheDayBefore;
    for (NSDate* day in last3Days)
    {
        NSString* dateStr = [CBDateUtils dateStringInLocalTimeZone:STANDARD_DATE_FORMAT andDate:day];

        NSMutableString* zipFileName = [NSMutableString stringWithString:dateStr];
//        [zipFileName appendString:FILE_EXTENDNAME_DOT_ZIP];
        
        NSString* placeHolderStr = nil;
        switch (dayIndex)
        {
            case TheDayBefore:
            {
                placeHolderStr = @"$TheDayBefore$";
                break;
            }
            case Yesterday:
            {
                placeHolderStr = @"$Yesterday$";
                break;
            }
            case Today:
            {
                placeHolderStr = @"$Today$";
                break;
            }
            default:
            {
                placeHolderStr = @"";
                break;
            }
        }
        
        for (int i = 0; i < 2; i++)
        {
            NSString* strAfterLinkReplaced = [CBStringUtils replaceSubString:zipFileName oldSubString:placeHolderStr string:htmlCodeCopy];
            htmlCodeCopy = [NSMutableString stringWithString:strAfterLinkReplaced];
        }
        
        dayIndex++;
    }
    
    NSData* data = [htmlCodeCopy dataUsingEncoding: encodingMode];

    NSString* torrentsPath = [SeedsDownloadAgent downloadPath];
    NSString* indexHtmlFilePath = [torrentsPath stringByAppendingPathComponent:URL_INDEXPAGE];
    
    flag = [CBFileUtils dataToFile:data filePath:indexHtmlFilePath];
    if (!flag)
    {
        DLog(@"Failed to generate index.html file.");
    }
    
    return flag;
}

-(NSString*) generateDownloadRootDirectory
{
    NSString* fullPath = nil;
    
    BOOL flag = NO;
    
    NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
    NSString* torrentsPath = [documentsPath stringByAppendingPathComponent:FOLDER_TORRENTS];
    
    flag = [CBPathUtils createDirectoryWithFullPath:torrentsPath];
    
    if (flag)
    {
        fullPath = torrentsPath;
    }
    
    return fullPath;
}

-(NSString*) generateDownloadSubDirectory:(NSString*) subDirName
{
    NSString* fullPath = nil;
    
    BOOL flag = NO;
    
    if (nil != subDirName && 0 < subDirName.length)
    {
        fullPath = [self generateDownloadRootDirectory];
        if (nil != fullPath)
        {
            NSString* subDirPath = [fullPath stringByAppendingPathComponent:subDirName];
            flag = [CBPathUtils createDirectoryWithFullPath:subDirPath];
            
            if (flag)
            {
                fullPath = subDirPath;
            }
            else
            {
                fullPath = nil;
            }
        }
    }
    
    return fullPath;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

@end
