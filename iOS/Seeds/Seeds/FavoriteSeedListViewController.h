//
//  FavoriteSeedListViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeedListTableCell.h"
#import "SeedDetailViewController.h"
#import "PagingToolbar.h"

#import "EGORefreshTableHeaderView.h"

@interface FavoriteSeedListViewController : UITableViewController <EGORefreshTableHeaderDelegate, PagingDelegate>

@end
