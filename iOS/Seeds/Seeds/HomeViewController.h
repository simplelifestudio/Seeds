//
//  HomeViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "SeedsSpider.h"
#import "TorrentListDownloadAgent.h"

@interface HomeViewController : UIViewController <MBProgressHUDDelegate, SeedsSpiderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIButton *transButton;

- (IBAction)onClickSyncButton:(id)sender;

@end
