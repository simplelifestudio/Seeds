//
//  AppDelegate.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserDefaultsModule.h"
#import "CommunicationModule.h"
#import "DatabaseModule.h"
#import "SpiderModule.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// System Module Declaration List
@property (strong, nonatomic) UserDefaultsModule *userDefaultsModule;
@property (strong, nonatomic) CommunicationModule *communicationModule;
@property (strong, nonatomic) DatabaseModule *databaseModule;
@property (strong, nonatomic) SpiderModule *spiderModule;

@end
