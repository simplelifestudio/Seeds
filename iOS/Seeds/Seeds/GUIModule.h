//
//  GUIModule.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-22.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBModuleAbstractImpl.h"
#import "CBSharedInstance.h"

#import "PAPasscodeViewController.h"
#import "HomeViewController.h"


@interface GUIModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate, PAPasscodeViewControllerDelegate>

@property (weak, nonatomic) HomeViewController* homeViewController;

-(void) showHUD:(NSString*) status delay:(NSInteger) seconds;

@end
