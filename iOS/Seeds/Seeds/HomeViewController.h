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

@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIButton *transButton;

- (IBAction)onClickSyncButton:(id)sender;

@end
