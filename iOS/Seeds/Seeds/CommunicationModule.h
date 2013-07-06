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
#import "SeedPictureAgent.h"
#import "SeedsDownloadAgent.h"

@interface CommunicationModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate>
{

}

@property (nonatomic, strong) SeedsSpider* spider;
@property (nonatomic, strong) ServerAgent* serverAgent;
@property (nonatomic, strong) SeedPictureAgent* seedPictureAgent;
@property (nonatomic, strong) SeedsDownloadAgent* seedsDownloadAgent;

@end
