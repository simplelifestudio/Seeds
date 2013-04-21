//
//  SplashViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

-(void) loadAnyNecessaryStuff;
-(void) startFadingSplashScreen;
-(void) finishFadingSplashScreen;

@end
