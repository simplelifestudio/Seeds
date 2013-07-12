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
#import "WarningViewController.h"

#import "CBHUDAgent.h"

@interface GUIModule : CBModuleAbstractImpl <CBSharedInstance, UIApplicationDelegate, PAPasscodeViewControllerDelegate>

@property (weak, nonatomic) HomeViewController* homeViewController;

@property (strong, nonatomic) CBHUDAgent* HUDAgent;

-(void) showHUD:(NSString*) majorStauts minorStatus:(NSString*) minorStatus delay:(NSInteger)seconds;
-(void) showHUD:(NSString*) status delay:(NSInteger) seconds;

-(WarningViewController*) getWarningViewController:(NSString*) warningId delegate:(id<WarningDelegate>) delegate;

- (BOOL) isNetworkActivityIndicatorVisible;
- (void) setNetworkActivityIndicatorVisible:(BOOL) flag;

@end
