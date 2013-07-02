//
//  CBMathUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBMathUtils.h"

@implementation CBMathUtils

+ (NSString*) readableStringFromBytesSize:(unsigned long long) bytesSize
{
    float floatSize = bytesSize;
    
    if (bytesSize < 1023)
    {
        return([NSString stringWithFormat:@"%llu bytes", bytesSize]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return([NSString stringWithFormat:@"%1.1f KB", floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return([NSString stringWithFormat:@"%1.1f MB", floatSize]);
    }
    
    floatSize = floatSize / 1024;
    return([NSString stringWithFormat:@"%1.1f GB", floatSize]);
}

@end
