//
//  SplashViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController <PAPasscodeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UILabel *appSlogan;

-(void) loadAnyNecessaryStuff;
-(void) startFadingSplashScreen;
-(void) finishFadingSplashScreen;

@end
