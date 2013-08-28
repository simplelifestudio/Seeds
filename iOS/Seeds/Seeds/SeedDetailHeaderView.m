//
//  SeedDetailHeaderView.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedDetailHeaderView.h"

@implementation SeedDetailHeaderView

@synthesize downloadLabel = _downloadLabel;
@synthesize favoriteLabel = _favoriteLabel;
@synthesize nameLabel = _nameLabel;
@synthesize formatLabel = _formatLabel;
@synthesize mosaicLabel = _mosaicLabel;
@synthesize pictureCountLabel = _pictureCountLabel;
@synthesize sizeLabel = _sizeLabel;

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

-(void) updateDownloadStatus:(SeedDownloadStatus) status
{
    switch (status)
    {
        case SeedNotDownload:
        {
            [_downloadLabel setHidden:YES];
            break;
        }
        case SeedWaitForDownload:
        {
            [_downloadLabel setText:NSLocalizedString(@"Downloading", nil)];
            [_downloadLabel setTextColor:COLOR_TEXT_LOG];
            [_downloadLabel setHidden:NO];
            break;
        }
        case SeedIsDownloading:
        {
            [_downloadLabel setText:NSLocalizedString(@"Downloading", nil)];
            [_downloadLabel setTextColor:COLOR_TEXT_LOG];
            [_downloadLabel setHidden:NO];
            break;
        }
        case SeedDownloaded:
        {
            [_downloadLabel setText:NSLocalizedString(@"Downloaded", nil)];
            [_downloadLabel setTextColor:COLOR_TEXT_LOG];
            [_downloadLabel setHidden:NO];
            break;
        }
        case SeedDownloadFailed:
        {
            [_downloadLabel setText:NSLocalizedString(@"Download Failed", nil)];
            [_downloadLabel setTextColor:COLOR_TEXT_WARNING];
            [_downloadLabel setHidden:NO];
            break;
        }
        default:
        {
            break;
        }
    }    
}

-(void) updateFavoriteStatus:(BOOL) favorite
{
    if (favorite)
    {
        [_favoriteLabel setText:NSLocalizedString(@"Favorited", nil)];
        [_favoriteLabel setTextColor:COLOR_TEXT_INFO];
        [_favoriteLabel setHidden:NO];
    }
    else
    {
        [_favoriteLabel setHidden:YES];
        [_favoriteLabel setText:NSLocalizedString(@"Unfavorited", nil)];
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
}

#pragma mark - Private Methods

- (void) _setupView
{
    _nameLabel.textColor = COLOR_TEXT_INFO;
    [GUIStyle formatFlatUILabel:_sizeLabel textColor:COLOR_TEXT_INFO];
    [GUIStyle formatFlatUILabel:_formatLabel textColor:COLOR_TEXT_INFO];
    [GUIStyle formatFlatUILabel:_mosaicLabel textColor:COLOR_TEXT_INFO];
    [GUIStyle formatFlatUILabel:_downloadLabel textColor:COLOR_TEXT_INFO];
    [GUIStyle formatFlatUILabel:_favoriteLabel textColor:COLOR_TEXT_INFO];
    [GUIStyle formatFlatUILabel:_pictureCountLabel textColor:COLOR_TEXT_INFO];
}

@end
