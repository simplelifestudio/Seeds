//
//  CBPathUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBPathUtils.h"

@implementation CBPathUtils

+(NSString*) documentsDirectoryPath
{
    NSArray * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [documentsPath objectAtIndex:0];
    
    return documentDirectory;
}

@end
