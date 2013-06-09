//
//  CBUIUtils.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-3.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol CBLongTaskStatusHUDDelegate <NSObject>

@required
-(void) taskStarted:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;
-(void) taskIsProcessing:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;
-(void) taskCanceld:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;
-(void) taskFailed:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;
-(void) taskFinished:(NSString*) majorStatus minorStatus:(NSString*) minorStatus;

@optional
-(void) taskDataUpdated:(id) dataLabel data:(id) data;

@end

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
