//
//  CBModuleAbstractImpl.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-21.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBModule.h"

#define MODULE_IDENTITY_ABSTRACT_IMPL @"AbstractImplementedModule"

@interface CBModuleAbstractImpl : NSObject <CBModule>

- (id)initWithIsIndividualThreadNecessary:(BOOL) necessary;

@end
