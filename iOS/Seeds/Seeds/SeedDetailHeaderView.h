//
//  SeedDetailHeaderView.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeedDetailHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UITextView *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UILabel *mosaicLabel;
@property (weak, nonatomic) IBOutlet UILabel *pictureCountLabel;

-(void) fillSeed:(Seed*) seed;

@end
