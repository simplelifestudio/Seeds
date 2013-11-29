//
//  HomeViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "CBUIUtils.h"

@interface HomeViewController : UIViewController <MBProgressHUDDelegate, CBLongTaskStatusHUDDelegate>

@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *theDayBeforeLabel;

@property (weak, nonatomic) IBOutlet UILabel *todaySyncStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesterdaySyncStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *theDayBeforeSyncStatusLabel;

@property (weak, nonatomic) IBOutlet FUIButton *todayButton;
@property (weak, nonatomic) IBOutlet FUIButton *yesterdayButton;
@property (weak, nonatomic) IBOutlet FUIButton *theDayBeforeButton;

- (IBAction)onClickTodayButton:(id)sender;
- (IBAction)onClickYesterdayButton:(id)sender;
- (IBAction)onClickTheDayBeforeButton:(id)sender;

@property (weak, nonatomic) IBOutlet FUIButton *syncButton;
@property (weak, nonatomic) IBOutlet FUIButton *transButton;
@property (weak, nonatomic) IBOutlet FUIButton *downloadsButton;
@property (weak, nonatomic) IBOutlet FUIButton *configButton;
@property (weak, nonatomic) IBOutlet FUIButton *helpButton;
@property (weak, nonatomic) IBOutlet UILabel *statuLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)onClickSyncButton:(id)sender;
- (IBAction)onClickDownloadButton:(id)sender;

@end
