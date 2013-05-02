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

@synthesize circularProgressView = _circularProgressVew;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    NSInteger radius = 60;
    CGFloat x = self.center.x - radius / 2;
    CGFloat y = self.center.y - radius / 2;
    NSInteger lineWidth = 10;
    _circularProgressVew = [[CircularProgressView alloc] initWithFrame:CGRectMake(x, y, radius, radius) backColor:COLOR_CIRCULAR_PROGRESS_BACKGROUND progressColor:COLOR_CIRCULAR_PROGRESS lineWidth:lineWidth];
    [self registerCircularProgressDelegate];
    
    [super awakeFromNib];
}

- (CircularProgressView*) circularProgerssView
{
    return _circularProgressVew;
}

- (void)registerCircularProgressDelegate
{
    self.circularProgressView.delegate = self;
    [self addSubview:_circularProgressVew];
}

- (void)didUpdateProgressView
{
    
}

- (void)didFisnishProgressView
{
    [_circularProgressVew removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
