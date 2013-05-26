//
//  SpiderModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

@interface SpiderModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>

@property (nonatomic, strong) SeedsSpider* spider;

@end
