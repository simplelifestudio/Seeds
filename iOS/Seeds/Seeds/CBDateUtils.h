//
//  CBDateUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STANDARD_DATE_TIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define STARDARD_DATE_FORMAT @"yyyy-MM-dd"

@interface CBDateUtils : NSObject

+(NSString*) dateString:(NSTimeZone*) timeZone andFormat:(NSString*) format andDate:(NSDate*) date;

+(NSString*) dateStringInLocalTimeZone:(NSString*) format andDate:(NSDate*) date;

+(NSString*) dateStringInLocalTimeZoneWithStandardFormat:(NSDate*) date;

+(NSDate *) dateFromStringWithFormat:(NSString *)dateString andFormat:(NSString *) formatString;

+(NSArray*) getContinuousThreeDays;

@end
