//
//  CBFileUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBFileUtils.h"

@implementation CBFileUtils

+(NSString*) newZipFileWithFiles:(NSString*) zipFileName zipFiles:(NSArray*) files;
{
    NSString* zipFilePath = nil;
    
    if (nil != zipFileName && 0 < zipFileName.length && nil != files && 0 < files.count)
    {
        NSString* documentsDir = [CBPathUtils documentsDirectoryPath];
        zipFilePath = [documentsDir stringByAppendingPathComponent:zipFileName];
        
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
                [zip close];
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
