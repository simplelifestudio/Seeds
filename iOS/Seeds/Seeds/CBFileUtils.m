//
//  CBFileUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBFileUtils.h"

@implementation CBFileUtils

+(NSString*) newZipFileWithFiles:(NSString*) zipFilePath zipFiles:(NSArray*) files;
{
    NSAssert(nil != zipFilePath && 0 < zipFilePath.length, @"Invalid zip file path.");
    
    if (nil != files && 0 < files.count)
    {        
        ZipFile *zip = [[ZipFile alloc] initWithFileName:zipFilePath mode:ZipFileModeCreate];
        
        for (NSString* file in files)
        {
            NSString* fileName = [file lastPathComponent];
            @try
            {
                ZipWriteStream* writeStream = [zip writeFileInZipWithName:fileName compressionLevel:ZipCompressionLevelNone];
                NSData* fileData = [self dataFromFile:file];
                [writeStream writeData:fileData];
                [writeStream finishedWriting];

            }
            @catch (NSException *e)
            {
                DLog(@"Failed to add file: %@ into zip.", fileName);
                DLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
                continue;
            }
            @finally
            {
                
            }
        }
        [zip close];
    }
    
    return zipFilePath;
}

+(NSData*) dataFromFile:(NSString *)filePath
{
    NSData *data = nil;

    @try
    {
        data = [NSData dataWithContentsOfFile: filePath];
    }
    @catch (NSException *e)
    {
        DLog(@"Failed to read data from file : %@", filePath);
        DLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
    @finally
    {
        
    }
    
    return data;
}

+(BOOL) dataToFile:(NSData*) data filePath:(NSString*) filePath;
{
    BOOL flag = NO;
    
    if (nil != data && nil != filePath)
    {
        flag = [data writeToFile:filePath atomically:YES];
    }
    
    return flag;
}

+(NSArray*) filesInDirectory:(NSString*) directoryPath fileExtendName:(NSString*) extendName
{
    NSMutableArray* files = [NSMutableArray array];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:directoryPath];
    
    NSString* file;
    while ((file = [dirEnum nextObject]))
    {
        BOOL filter = NO;
        
        if (nil != extendName && 0 < extendName)
        {
            if ([[file pathExtension] isEqualToString: extendName])
            {
                filter = YES;
            }
        }
        else
        {
            filter = YES;
        }
        
        if (filter)
        {
            NSString* fileFullPath = [directoryPath stringByAppendingPathComponent:file];
            [files addObject:fileFullPath];
        }
    }
    
    return files;
}

//+(NSString*) createZipArchiveWithFiles:(NSArray*)files andPassword:(NSString*)password
//{
//    ZipArchive* zip = [[ZipArchive alloc] init];
////    const char* tempName = tempnam("../Documents/tmp", "ziparchive");
//    BOOL ok;
//    NSString* zipPath = [NSString stringWithFormat:@"%@.zip", @"test"];
//    NSString *documentsDir = [CBPathUtils documentsDirectoryPath];
//    zipPath = [documentsDir stringByAppendingPathComponent:zipPath];
//    
//    if (password && password.length > 0)
//    {
//        ok = [zip CreateZipFile2:zipPath Password:password];
//    }
//    else
//    {
//        ok = [zip CreateZipFile2:zipPath];
//    }
//    
//    if (ok)
//    {
//        DLog(@"Zip file is created.");
//        for (NSString* file in files)
//        {
//            ok = [zip addFileToZip:file newname:[file lastPathComponent]];
//            if (ok)
//            {
//                DLog(@"Added file:%@ into zip archive successfully.", file);
//            }
//            else
//            {
//                DLog(@"Failed to add file:%@ into zip archive.", file);
//            }
//        }
//        
//        ok = [zip CloseZipFile2];
//        if (ok)
//        {
//            DLog(@"Closed zip file successfully.");
//        }
//        else
//        {
//            DLog(@"Failed to close zip file.");
//        }
//    }
//    DLog(@"zipPath:%@", zipPath);
//    return zipPath;
//}

@end
