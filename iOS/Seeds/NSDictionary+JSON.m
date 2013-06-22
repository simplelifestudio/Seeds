//
//  NSDictionary+JSON.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (Json)

+(NSDictionary*) dictionaryWithContentsOfURLString:(NSString*)urlAddress
{
    NSDictionary* dic = nil;
    
    if (nil != urlAddress && 0 < urlAddress.length)
    {
        NSURL* url = [NSURL URLWithString: urlAddress];
        NSData* data =[NSData dataWithContentsOfURL:url];
        
        __autoreleasing NSError *error = nil;
        dic =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        dic = (nil == error) ? dic : nil;
    }
    
    return dic;
}

-(NSData*) toJSON
{
    NSData* data = nil;
    
    NSError *error = nil;
    data =[NSJSONSerialization dataWithJSONObject:self
                                               options:kNilOptions error:&error];    
    data = (nil == error) ? data : nil;
    
    return data;
}

@end
