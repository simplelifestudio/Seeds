//
//  SeedPictureCollectionCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureCollectionCell.h"
#import "SeedPictureAgent.h"

@interface SeedPictureCollectionCell()
{

}

@end

@implementation SeedPictureCollectionCell

@synthesize asyncImageView = _asyncImageView;
@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupCell];
    
    [super awakeFromNib];
}

- (void) setupCell
{
    _asyncImageView.thumbnailType = SeedPictureCollectionCellThumbnail;
}

-(void) fillSeedPicture:(SeedPicture*) picture pictureIdInSeed:(NSUInteger) pictureIdInSeed
{
    if (nil == picture || picture.isPlaceHolder)
    {
        UIImage* image = [SeedPictureAgent exceptionImageWithThumbnailType:SeedPictureCollectionCellThumbnail imageExceptionType:EmptyImage];
        [_asyncImageView loadImageFromLocal:image];
        
        _label.text = [NSString stringWithFormat:@"%d", 1];
    }
    else
    {
        NSURL* imageURL = [[NSURL alloc] initWithString:picture.pictureLink];
        [_asyncImageView loadImageFromURL:imageURL];
        
        _label.text = [NSString stringWithFormat:@"%d", pictureIdInSeed];
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [_asyncImageView removeFromSuperview];
    
    CGRect rect = self.frame;
    CGRect rectImageView = CGRectMake(0, 0, rect.size.width, rect.size.height - _label.frame.size.height);
    AsyncImageView* newImageView = [[AsyncImageView alloc] initWithFrame:rectImageView];
    newImageView.thumbnailType = _asyncImageView.thumbnailType;
    _asyncImageView = newImageView;
    [self addSubview:_asyncImageView];
}

@end
