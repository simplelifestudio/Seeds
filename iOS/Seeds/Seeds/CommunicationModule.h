//
//  CommunicationModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "SeedsSpider.h"

@interface CommunicationModule : CBModuleAbstractImpl

@property (nonatomic, strong) SeedsSpider* spider;

@end
