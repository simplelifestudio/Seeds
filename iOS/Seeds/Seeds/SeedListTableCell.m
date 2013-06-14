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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupCell];
    }
    return self;
}

- (void) setupCell
{
    _asyncImageView.thumbnailType = SeedListTableCellThumbnail;
}

- (void)awakeFromNib
{
    [self setupCell];
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) fillSeed:(Seed*) seed
{
    if (nil != seed)
    {
        [_nameLabel setText:seed.name];
        [_sizeLabel setText:seed.size];
        [_formatLabel setText:seed.format];
        [_mosaicLabel setText:(seed.mosaic) ? NSLocalizedString(@"Mosaic", nil) : NSLocalizedString(@"No-Mosaic", nil)];
    }
}

-(void) fillSeedPicture:(SeedPicture*) picture
{
    if (nil == picture || picture.isPlaceHolder)
    {
        UIImage* image = [SeedPictureAgent exceptionImageWithThumbnailType:SeedListTableCellThumbnail imageExceptionType:EmptyImage];
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
    
    CGRect cellRect = self.frame;
    
    AsyncImageView* newImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL, cellRect.size.height)];
    newImageView.thumbnailType = _asyncImageView.thumbnailType;
    _asyncImageView = newImageView;
    [self addSubview:_asyncImageView];
}

@end
