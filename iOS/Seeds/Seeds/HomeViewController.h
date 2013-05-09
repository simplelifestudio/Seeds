//
//  HomeViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface HomeViewController : UIViewController <MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIButton *syncButton;

- (IBAction)onClickSyncButton:(id)sender;

@end
