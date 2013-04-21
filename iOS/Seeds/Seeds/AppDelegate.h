//
//  AppDelegate.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommunicationModule.h"
#import "DatabaseModule.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CommunicationModule *communicationModule;
@property (strong, nonatomic) DatabaseModule *databaseModule;

@end
