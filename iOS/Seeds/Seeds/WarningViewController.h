//
//  WarningViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarningViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

- (IBAction)onClickAgreeButton:(id)sender;
- (IBAction)onClickDeclineButton:(id)sender;

@end
