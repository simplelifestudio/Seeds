//
//  CBUIUtils.h
//  iSignal
//
//  Created by Patrick Deng on 11-8-22.
//  Copyright 2011 CodeBeaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CBUIUtils : NSObject

+(id<UIApplicationDelegate>) getAppDelegate;

+(UIViewController*) getViewControllerFromView:(UIView*) view;

+(UIWindow*) getWindow:(UIView*) view;

+(UIWindow*) getKeyWindow;

+(void)removeSubViews:(UIView*) superView;

+(void) showInformationAlertWindow:(id) delegate andMessage:(NSString*) message;
+(void) showInformationAlertWindow:(id) delegate andError:(NSError*) error;

+(UIAlertView*) createProgressAlertView:(NSString *) title andMessage:(NSString *) message andActivity:(BOOL) activity andDelegate:(id) delegate;

@end
