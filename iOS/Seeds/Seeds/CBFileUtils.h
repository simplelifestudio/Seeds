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

+(NSString*) newZipFileWithFiles:(NSString*) zipFilePath zipFiles:(NSArray*) files;
+(NSData*) dataFromFile:(NSString*) filePath;
+(BOOL) dataToFile:(NSData*) data filePath:(NSString*) filePath;
+(NSArray*) filesInDirectory:(NSString*) directoryPath fileExtendName:(NSString*) extendName;
+(NSArray*) directories:(NSString*) directoryPath;

+(NSDate*) fileLastUpdateTime:(NSString*) fileFullPath;
+(BOOL) deleteFile:(NSString*) fileFullPath;
+(BOOL) createFile:(NSString*) fileFullPath content:(id) content;
+(BOOL) createDirectory:(NSString*) dirFullPath;
+(BOOL) isFileExists:(NSString*) fileFullPath;
+(BOOL) isDirectoryExists:(NSString*) dirFullPath;
+(BOOL) deleteDirectory:(NSString*) dirFullPath;
+(BOOL) copyFile:(NSString*) sourcePath targetPath:(NSString*) targetPath;

@end
