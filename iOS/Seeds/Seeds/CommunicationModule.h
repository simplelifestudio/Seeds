//
//  CommunicationModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "SeedsSpider.h"
#import "ServerAgent.h"

#define RACHABILITY_HOST @"www.apple.com"

@interface CommunicationModule : CBModuleAbstractImpl <CBSharedInstance>
{

}

@property (nonatomic, strong) SeedsSpider* spider;
@property (nonatomic, strong) ServerAgent* serverAgent;

@end
