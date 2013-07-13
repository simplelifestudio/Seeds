//
//  SeedListTableCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedListTableCell.h"

#import "SeedPictureAgent.h"

@interface SeedListTableCell()
{

}
@end

@implementation SeedListTableCell

@synthesize nameLabel = _nameLabel;
@synthesize formatLabel = _formatLabel;
@synthesize mosaicLabel = _mosaicLabel;
@synthesize asyncImageView = _asyncImageView;
@synthesize downloadLabel = _downloadLabel;
@synthesize favoriteLabel = _favoriteLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _setupCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupCell];
    
    [super awakeFromNib];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
    
    CGRect rect = self.contentView.bounds;
    UIView* view = [[UIView alloc] initWithFrame:rect];
    if (selected)
    {
        [view setBackgroundColor:[UIColor clearColor]];
        
        [self setSelectedBackgroundView:view];
    }
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

-(void) fillSeedPicture:(SeedPicture*) picture
{
    if (nil == picture || picture.isPlaceHolder)
    {
        UIImage* image = [SeedPictureAgent exceptionImageWithImagelType:ListTableCellThumbnail imageExceptionType:EmptyImage];
        [_asyncImageView loadImageFromLocal:image];
    }
    else
    {
        NSURL* imageURL = [[NSURL alloc] initWithString:picture.pictureLink];
        [_asyncImageView loadImageFromURL:imageURL];
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [_asyncImageView removeFromSuperview];
    
    CGFloat x = _asyncImageView.frame.origin.x;
    CGFloat y = _asyncImageView.frame.origin.y;
    AsyncImageView* newImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(x, y, WIDTH_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL, HEIGHT_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL)];
    newImageView.imageType = ListTableCellThumbnail;
    _asyncImageView = newImageView;
    [self.contentView addSubview:_asyncImageView];
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
            [_downloadLabel setTextColor:COLOR_TEXT_INFO];
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

#pragma mark - Private Methods

- (void) _setupCell
{
    _asyncImageView.imageType = ListTableCellThumbnail;
}

@end
