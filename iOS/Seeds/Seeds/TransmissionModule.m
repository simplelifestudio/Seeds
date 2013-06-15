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
    NSString* webPath = [CBPathUtils documentsDirectoryPath];
    webPath = [webPath stringByAppendingPathComponent:FOLDER_TORRENTS];
	DLog(@"HTTP server document root: %@", webPath);
	[httpServer setDocumentRoot:webPath];
    
    [super startService];
}

-(void) processService
{
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

-(BOOL)generateHtmlPage:(NSArray*) last3Days;
{
    NSAssert(nil != last3Days, @"Date array is nil.");
    
    BOOL flag = NO;
    
    int encodingMode = NSUTF8StringEncoding;
    
    if (nil == htmlCode)
    {
        NSString* htmlFilePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        NSData* data = [CBFileUtils dataFromFile:htmlFilePath];
        htmlCode = [[NSString alloc] initWithData:data encoding:encodingMode];
    }
    
    NSMutableString* htmlCodeCopy = [NSMutableString stringWithString:htmlCode];
    for (NSDate* day in last3Days)
    {
        NSString* dateStr = [CBDateUtils shortDateString:day];

        NSMutableString* zipFileName = [NSMutableString stringWithString:dateStr];
        [zipFileName appendString:FILE_EXTENDNAME_DOT_ZIP];
        
        NSString* strAfterLinkReplaced = [CBStringUtils replaceSubString:zipFileName oldSubString:@"$LINK$" string:htmlCodeCopy];
        htmlCodeCopy = [NSMutableString stringWithString:strAfterLinkReplaced];
        
        NSString* strAfterDateReplaced = [CBStringUtils replaceSubString:dateStr oldSubString:@"$NAME$" string:htmlCodeCopy];
        htmlCodeCopy = [NSMutableString stringWithString:strAfterDateReplaced];
    }
    
    NSData* data = [htmlCodeCopy dataUsingEncoding: encodingMode];

    NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
    NSString* torrentsPath = [documentsPath stringByAppendingPathComponent:FOLDER_TORRENTS];
    NSString* indexHtmlFilePath = [torrentsPath stringByAppendingPathComponent:@"index.html"];
    
    flag = [CBFileUtils dataToFile:data filePath:indexHtmlFilePath];
    if (!flag)
    {
        DLog(@"Failed to generate index.html file.");
    }
    
    return flag;
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
