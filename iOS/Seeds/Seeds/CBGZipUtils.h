//
//  CBGZipUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zlib.h"

@interface CBGZipUtils : NSObject

+(NSData*) gzipData:(NSData*) pUncompressedData;
+(NSData*) uncompressZippedData:(NSData*) compressedData;

@end
