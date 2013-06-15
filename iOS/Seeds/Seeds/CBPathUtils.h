//
//  CBPathUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBPathUtils : NSObject

+(NSString*) documentsDirectoryPath;

+(BOOL) createDirectoryWithFullPath:(NSString*) fullPath;

@end
