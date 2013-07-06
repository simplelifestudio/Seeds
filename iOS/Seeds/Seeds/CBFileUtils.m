//
//  CBFileUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBFileUtils.h"

@implementation CBFileUtils

+(NSDate*) fileLastUpdateTime:(NSString*) fileFullPath
{
    NSDate* time = nil;
    
    if (nil != fileFullPath && 0 < fileFullPath)
    {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* fileAttributes = [fm attributesOfItemAtPath:fileFullPath error:nil];
        time = [fileAttributes objectForKey:NSFileModificationDate];
    }
    
    return time;
}

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

+(BOOL) isFileExists:(NSString*) fileFullPath
{
    BOOL flag = NO;
    
    NSFileManager * fm = [NSFileManager defaultManager];
    flag = [fm fileExistsAtPath:fileFullPath];
    
    return flag;
}

+(BOOL) deleteFile:(NSString*) fileFullPath
{
    BOOL flag = NO;
    
    if (nil != fileFullPath && 0 < fileFullPath.length)
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError* error = nil;
        
        flag = [CBFileUtils isFileExists:fileFullPath];
        if (flag)
        {
            flag = [fm removeItemAtPath:fileFullPath error:&error];
            if (!flag)
            {
                DLog(@"Failed to delete file at path: %@ with error: %@", fileFullPath, error.localizedDescription);
            }
        }
    }
    
    return flag;
}

+(BOOL) isDirectoryExists:(NSString*) dirFullPath
{
    BOOL flag = NO;
    
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDir;
    flag = [fm fileExistsAtPath:dirFullPath isDirectory:&isDir];
    flag = (flag && isDir) ? YES : NO;
    
    return flag;
}

+(BOOL) deleteDirectory:(NSString*) dirFullPath
{
    BOOL flag = NO;
    
    if (nil != dirFullPath && 0 < dirFullPath.length)
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError* error = nil;
        
        flag = [CBFileUtils isDirectoryExists:dirFullPath];
        if (flag)
        {
            flag = [fm removeItemAtPath:dirFullPath error:&error];
            if (!flag)
            {
                DLog(@"Failed to delete file at path: %@ with error: %@", dirFullPath, error.localizedDescription);
            }
        }
    }
    
    return flag;
}

+(BOOL) createFile:(NSString*) fileFullPath content:(id)content
{
    BOOL flag = NO;
    
    if (nil != fileFullPath && 0 < fileFullPath.length)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        flag = [fm createFileAtPath:fileFullPath contents:content attributes:nil];
    }
    
    return flag;
}

+(BOOL) createDirectory:(NSString*) dirFullPath
{
    BOOL flag = NO;
    
    if (nil != dirFullPath && 0 < dirFullPath.length)
    {
        NSFileManager* fm = [NSFileManager defaultManager];
        flag = [fm createDirectoryAtPath:dirFullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return flag;
}

+(NSArray*) directories:(NSString*) directoryPath
{
    NSMutableArray* dirs = [NSMutableArray array];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* subDirs = [fm contentsOfDirectoryAtPath:directoryPath error:nil];
    if (nil != subDirs && 0 < subDirs.count)
    {
        [dirs addObjectsFromArray:subDirs];
    }
    
    return dirs;
}

@end
