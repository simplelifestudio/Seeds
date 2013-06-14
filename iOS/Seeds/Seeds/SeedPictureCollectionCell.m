//
//  SeedPictureCollectionCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-26.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SeedPictureCollectionCell.h"

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
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void) fillSeedPicture:(SeedPicture *)picture
{
    if (nil == picture || picture.isPlaceHolder)
    {
        NSString *placeHolderPath = [[NSBundle mainBundle] pathForResource:@"noImage_collectionCell" ofType:@"png"];
        UIImage *placeHolderImage = [[UIImage alloc] initWithContentsOfFile:placeHolderPath];
        [_asyncImageView loadImageFromLocal:placeHolderImage];
        _label.text = nil;
    }
    else
    {
        NSURL* imageURL = [[NSURL alloc] initWithString:picture.pictureLink];
        [_asyncImageView loadImageFromURL:imageURL];
        
        _label.text = [NSString stringWithFormat:@"%d", picture.pictureId];
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [_asyncImageView removeFromSuperview];
    
    CGRect rect = self.frame;
    CGRect rectImageView = CGRectMake(0, 0, rect.size.width, rect.size.height - _label.frame.size.height);
    AsyncImageView* newImageView = [[AsyncImageView alloc] initWithFrame:rectImageView];
    _asyncImageView = newImageView;
    [self addSubview:_asyncImageView];
}

@end
