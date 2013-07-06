//
//  TransmitModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBNetworkUtils.h"

@interface TransmissionModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

-(BOOL) startHTTPServer;
-(void) stopHTTPServer;

-(NSInteger) httpServerPort;
-(NSString*) httpServerName;

-(BOOL)generateHtmlPageWithZipFileName:(NSString*) zipFileName;
-(BOOL) generateHtmlPageWithLast3Days:(NSArray*) last3Days;

-(NSString*) generateDownloadRootDirectory;
-(NSString*) generateDownloadSubDirectory:(NSString*) subDirName;

@end
