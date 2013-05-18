//
//  CBFileUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBFileUtils.h"

@implementation CBFileUtils

+(NSData*) dataFromFile:(NSString *)filePath
{
    NSData *data = nil;

    @try
    {
        data = [NSData dataWithContentsOfFile: filePath];
    }
    @catch (NSException *e)
    {
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
