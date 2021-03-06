//
//  CartIdViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartIdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet FUIButton *changeButton;
@property (weak, nonatomic) IBOutlet FUIButton *clipboardButton;

+(NSString*) composeFullCartLink:(NSString*) cartId;
+(NSString*) decomposeCartIdFromFullCartLink:(NSString*) fullCartLink;

- (IBAction)onClickClipboardButton:(id)sender;
- (IBAction)onClickChangeButton:(id)sender;

@end
