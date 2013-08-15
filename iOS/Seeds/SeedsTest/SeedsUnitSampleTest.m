//
//  SeedsUnitSampleTest.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-15.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedsUnitSampleTest.h"

@implementation SeedsUnitSampleTest

- (void)testStrings
{
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNULL("Aloha", nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

- (void)testSimpleFail
{
    GHAssertTrue(YES, nil);
}

@end
