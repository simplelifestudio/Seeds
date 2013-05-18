//
//  TransmitModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmissionModule.h"

#import "HTTPServer.h"

@interface TransmissionModule()
{
    HTTPServer* httpServer;
}

@end

@implementation TransmissionModule

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
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	// [httpServer setPort:12345];
	
	// Serve files from our embedded Web folder
//	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"../Documents"];
    NSString* webPath = [CBPathUtils documentsDirectoryPath];
	DLog(@"Setting document root: %@", webPath);
	[httpServer setDocumentRoot:webPath];
    
    [super startService];
}

-(void) processService
{
    [NSThread sleepForTimeInterval:0.5];
}

- (void)startHTTPServer
{
	NSError *error;
	if([httpServer start:&error])
	{
		DLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		DLog(@"Error starting HTTP Server: %@", error);
	}
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

@end
