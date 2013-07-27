//
//  DownloadSeedListViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeedDetailViewController.h"
#import "PagingToolbar.h"

#import "EGORefreshTableHeaderView.h"

@interface DownloadSeedListViewController : UITableViewController <EGORefreshTableHeaderDelegate, PagingDelegate>

@end
