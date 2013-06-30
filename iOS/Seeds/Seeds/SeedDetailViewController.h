//
//  SeedDetailViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeedPictureCollectionCell.h"
#import "SeedPictureViewController.h"
#import "SeedDetailHeaderView.h"
#import "PagingToolbar.h"

#import "TorrentDownloadAgent.h"

@interface SeedDetailViewController : UICollectionViewController <TorrentDownloadAgentDelegate, PagingDelegate>

@property (nonatomic, strong) Seed* seed;

@end
