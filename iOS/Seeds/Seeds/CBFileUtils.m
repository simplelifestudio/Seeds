//
//  CBFileUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBFileUtils.h"

@implementation CBFileUtils

/*
 NSString *documentsDir = [CBPathUtils documentsDirectoryPath];
 
 NSString* torrentFullPath = [documentsDir stringByAppendingPathComponent:@"TDIsOck5la.torrent"];
 
 NSString *filePath = [documentsDir stringByAppendingPathComponent:@"test.zip"];
 
 ZipFile *zipFile = [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];
 
 //向当前Zip文件中添加文件需要使用ZipFileModeAppend模式
 ZipWriteStream *writeStream = [zipFile writeFileInZipWithName:@"TDIsOck5la.torrent" compressionLevel:ZipCompressionLevelNone];
 //yourfilename是存入的文件名
 //compressionLevel指示压缩率级别，可以选择ZipCompressionLevelFast(最快), ZipCompressionLevelBest(最大压缩率)，ZipCompressionLevelNone(不压缩)
 //如果使用密码和CRC校验可以使用另外的写入函数
 NSData* data = [CBFileUtils dataFromFile:torrentFullPath];
 [writeStream writeData:data];
 //data是需要压入的文件内容(NSData类型)
 [writeStream finishedWriting];
 [zipFile close];
 */
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
