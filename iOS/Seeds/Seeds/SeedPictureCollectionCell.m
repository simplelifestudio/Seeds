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
        [self _setupCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupCell];
    
    [super awakeFromNib];
}

-(void) fillSeedPicture:(SeedPicture*) picture pictureIdInSeed:(NSUInteger) pictureIdInSeed
{
    if (nil == picture || picture.isPlaceHolder)
    {
        UIImage* image = [SeedPictureAgent exceptionImageWithImagelType:PictureCollectionCellThumbnail imageExceptionType:EmptyImage];
        [_asyncImageView loadImageFromLocal:image];
        
        _label.text = [NSString stringWithFormat:@"%d", pictureIdInSeed];
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
    
    CGFloat x = _asyncImageView.frame.origin.x;
    CGFloat y = _asyncImageView.frame.origin.y;
    
    CGRect rectImageView = CGRectMake(x, y, rect.size.width, rect.size.height - _label.frame.size.height);
    AsyncImageView* newImageView = [[AsyncImageView alloc] initWithFrame:rectImageView];
    newImageView.imageType = PictureCollectionCellThumbnail;
    _asyncImageView = newImageView;
    [self addSubview:_asyncImageView];
}

#pragma mark - Private Methods

- (void) _setupCell
{
    _asyncImageView.imageType = PictureCollectionCellThumbnail;
}

@end
