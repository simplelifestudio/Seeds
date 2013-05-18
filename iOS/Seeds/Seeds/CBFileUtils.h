//
//  CBFileUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ZipArchive.h"

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

@interface CBFileUtils : NSObject

//// Need 3rd lib: ZipArchive support
//+(NSString*) createZipArchiveWithFiles:(NSArray*)files andPassword:(NSString*)password;

+(NSData*) dataFromFile:(NSString*) filePath;

@end
