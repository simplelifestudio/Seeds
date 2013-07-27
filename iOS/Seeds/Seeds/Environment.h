//
//  Environment.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-23.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Environment : NSObject

+(NSString*) databaseFilePath;
+(NSString*) databaseFilePathInXcodeProject;
+(NSString*) torrentsDirPath;

@end
