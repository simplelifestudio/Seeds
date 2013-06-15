//
//  SeedDetailHeaderView.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDetailHeaderView.h"

@implementation SeedDetailHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupView];
    
    [super awakeFromNib];
}

- (void) _setupView
{
    
}

-(void) fillSeed:(Seed*) seed
{
    if (nil != seed)
    {
        [_nameLabel setText:seed.name];
        [_sizeLabel setText:seed.size];
        [_formatLabel setText:seed.format];
        [_mosaicLabel setText:(seed.mosaic) ? NSLocalizedString(@"Mosaic", nil) : NSLocalizedString(@"No-Mosaic", nil)];
        NSMutableString* picCountStr = [NSMutableString stringWithFormat:@"%d", seed.seedPictures.count];
        [picCountStr appendString:NSLocalizedString(@"Picture", nil)];
        [_pictureCountLabel setText:picCountStr];
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
}

@end
