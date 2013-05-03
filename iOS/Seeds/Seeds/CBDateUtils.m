//
//  CBDateUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBDateUtils.h"

@implementation CBDateUtils

+(NSString*) dateString:(NSTimeZone*) timeZone andFormat:(NSString*) format andDate:(NSDate*) date
{
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    timeZone = (nil != timeZone) ? timeZone : [NSTimeZone defaultTimeZone];
    [formatter setTimeZone:timeZone];
    
    NSString *localTime = [formatter stringFromDate:date];
    
    return localTime;
}

+(NSString*) dateStringInLocalTimeZone:(NSString*) format andDate:(NSDate*) date
{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    return [CBDateUtils dateString: localTimeZone andFormat:format andDate: date];
}

+(NSString*) dateStringInLocalTimeZoneWithStandardFormat:(NSDate*) date
{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    return [CBDateUtils dateString:localTimeZone andFormat:STANDARD_DATE_TIME_FORMAT andDate:date];
}

+(NSDate *) dateFromStringWithFormat:(NSString *)dateString andFormat:(NSString *) formatString
{    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: formatString];
	NSDate *date = [dateFormatter dateFromString:dateString];
    
	return date;
}

+(NSArray*) getContinuousThreeDays
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:3];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    NSDate *tomorrow = [[NSDate alloc]
                        initWithTimeIntervalSinceNow:secondsPerDay];
    
    NSDate *today = [NSDate date];
    
    NSDate *yesterday = [[NSDate alloc]
                         initWithTimeIntervalSinceNow:-secondsPerDay];

    [array addObject:tomorrow];
    [array addObject:today];
    [array addObject:yesterday];
    
    return array;
}

- (id)init
{
    return nil;
    // Disable object initialization.
    //    self = [super init];
    //    if (self) 
    //    {
    //        // Initialization code here.
    //    }
    //    
    //    return self;
}

@end
