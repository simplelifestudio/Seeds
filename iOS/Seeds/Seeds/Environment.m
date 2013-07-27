//
//  Environment.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "Environment.h"

@implementation Environment

+(NSString*) databaseFilePath
{
    NSString* _databaseFilePath = nil;
    
    NSString* documentsDir = [CBPathUtils documentsDirectoryPath];
    NSString* appDocumentsDir = [documentsDir stringByAppendingPathComponent:APP_NAME];
    
    _databaseFilePath = [appDocumentsDir stringByAppendingPathComponent:DATABASE_FILE_FULL_NAME];
    DLog(@"Database File in App Sandbox: %@", _databaseFilePath);
    
    return _databaseFilePath;
}

+(NSString*) databaseFilePathInXcodeProject
{
    NSString* _path = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_TYPE];
    return _path;
}

+(NSString*) torrentsDirPath
{
    NSString* _torrentsDirPath = nil;
    
    NSString* documentsDir = [CBPathUtils documentsDirectoryPath];
    NSString* appDocumentsDir = [documentsDir stringByAppendingPathComponent:APP_NAME];    
    _torrentsDirPath = [appDocumentsDir stringByAppendingPathComponent:FOLDER_TORRENTS];
    
    return _torrentsDirPath;
}

@end
