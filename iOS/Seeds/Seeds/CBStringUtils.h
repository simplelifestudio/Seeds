//
//  CBStringUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STR_COLON @":"
#define STR_COLON_FULLWIDTH_1 @"︰"
#define STR_COLON_FULLWIDTH_2 @"："

#define STR_BRACKET_LEFT @"["
#define STR_BRACKET_RIGHT @"]"

#define STR_SPACE @" "

@interface CBStringUtils : NSObject

+(BOOL) isSubstringIncluded:(NSString*) parentString subString:(NSString*)subString;
+(NSString*) trimString:(NSString*) string;
+(NSString*) replaceSubString:(NSString*) newSubString oldSubString:(NSString*)oldSubString string:(NSString*) string;

@end
