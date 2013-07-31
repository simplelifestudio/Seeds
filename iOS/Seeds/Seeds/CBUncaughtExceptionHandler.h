//
//  CBUncaughtExceptionHandler.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-24.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBUncaughtExceptionHandler : NSObject
{
	BOOL dismissed;
}

@end

void InstallUncaughtExceptionHandler();
