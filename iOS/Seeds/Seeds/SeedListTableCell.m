//
//  SeedListTableCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedListTableCell.h"

@interface SeedListTableCell()
{

}
@end

@implementation SeedListTableCell

@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize nameLabel = _nameLabel;
@synthesize formatLabel = _formatLabel;
@synthesize mosaicLabel = _mosaicLabel;

@synthesize circularProgressView = _circularProgressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    NSInteger radius = 40;
    CGFloat x = 50 - radius / 2;
    CGFloat y = 50 - radius / 2;
    NSInteger lineWidth = 6;
    _circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(x, y, radius, radius) backColor:COLOR_CIRCULAR_PROGRESS_BACKGROUND progressColor:COLOR_CIRCULAR_PROGRESS lineWidth:lineWidth];
    [self registerCircularProgressDelegate];
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    if (nil == picture)
    {
        [self.circularProgressView removeFromSuperview];
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:@"noImage_tableCell" ofType:@"png"];
        UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
        [_thumbnailImageView setImage:placeHolderImage];
    }
}

- (CircularProgressView*) circularProgerssView
{
    return _circularProgressView;
}

- (void)registerCircularProgressDelegate
{
    self.circularProgressView.delegate = self;
    [self addSubview:_circularProgressView];
}

- (void)didUpdateProgressView
{
    
}

- (void)didFisnishProgressView
{
    [_circularProgressView removeFromSuperview];
}

- (void) dealloc
{
    [self setCircularProgressView:nil];
}

@end
