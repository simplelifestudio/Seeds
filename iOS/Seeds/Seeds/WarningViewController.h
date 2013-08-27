//
//  WarningViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WarningDelegate <NSObject>

@required
-(void) countdownFinished:(NSString*) warningId;
-(void) agreeButtonClicked:(NSString*) warningId;
-(void) declineButtonClicked:(NSString*) warningId;

@end

@interface WarningViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet FUIButton *agreeButton;
@property (weak, nonatomic) IBOutlet FUIButton *declineButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *warningNavigationItem;

@property (weak, nonatomic) id<WarningDelegate> warningDelegate;

@property (strong, nonatomic) NSString* warningId;

- (IBAction)onClickAgreeButton:(id)sender;
- (IBAction)onClickDeclineButton:(id)sender;

- (void) setWarningText:(NSString*) text;
- (void) setCountdownSeconds:(NSUInteger) seconds;
- (void) setAgreeButtonVisible:(BOOL) visible;
- (void) setDeclineButtonVisible:(BOOL) visible;

@end
