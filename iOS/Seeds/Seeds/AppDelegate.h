//
//  AppDelegate.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBModuleManager.h"

#import "CrashReportModule.h"
#import "GUIModule.h"
#import "UserDefaultsModule.h"
#import "CommunicationModule.h"
#import "DatabaseModule.h"
#import "SpiderModule.h"
#import "TransmissionModule.h"
#import "WebSocketModule.h"
#import "LoggerModule.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CBModuleManager* moduleManager;

@end
