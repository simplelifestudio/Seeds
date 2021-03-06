//
//  CircularProgressView.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CircularProgressView.h"

@interface CircularProgressView ()

@property (assign, nonatomic) float progress;
@property (assign, nonatomic) float total;

@end

@implementation CircularProgressView

@synthesize viewLocation = _viewLocation;
@synthesize backColor = _backColor;
@synthesize progressColor = _progressColor;
@synthesize lineWidth = _lineWidth;

@synthesize imageType = _imageType;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _backColor = backColor;
        _progressColor = progressColor;
        _lineWidth = lineWidth;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2);
    CGFloat radius = self.bounds.size.width / 2 - self.lineWidth / 2;
    CGFloat startAngle = (CGFloat) - M_PI_2;
    CGFloat endAngle = (CGFloat) 1.5 * M_PI;
    BOOL clockWise = YES;
    
    //draw background circle
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockWise];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (0 < _total)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();        
        UIGraphicsPushContext(context);
        
        NSUInteger fontSize = 0;
        switch (_imageType)
        {
            case ListTableCellThumbnail:
            {
                fontSize = 0;
                break;
            }
            case PictureCollectionCellThumbnail:
            {
                fontSize = 10;
                break;
            }
            case PictureViewThumbnail:
            {
                fontSize = 16;
                break;
            }
            case PictureViewFullImage:
            {
                fontSize = 18;
                break;
            }
            default:
            {
                break;
            }
        }
        
        if (IS_IPHONE5)
        {
            fontSize = fontSize * FONT_SIZE_ZOOMRATE_CIRCULARVIEW_FOR_IPHONE5;
        }
        else if (IS_IPHONE4_OR_4S)
        {
            fontSize = round(fontSize * FONT_SIZE_ZOOMRATE_CIRCULARVIEW_FOR_IPHONE4_OR_4S);
        }
        else if (IS_IPAD1_OR_2_OR_MINI)
        {
            fontSize = round(fontSize * FONT_SIZE_ZOOMRATE_CIRCULARVIEW_FOR_IPAD1_OR_2_OR_MINI);
        }
        
        if (0 < fontSize)
        {
            NSString* title = [CBMathUtils readableStringFromBytesSize:_total];
            UIFont* font = [UIFont systemFontOfSize:fontSize];
            CGSize labelSize = [title sizeWithFont:font];
            CGPoint labelCenterPoint = CGPointMake(centerPoint.x - labelSize.width / 2, centerPoint.y - labelSize.height / 2);
            [title drawAtPoint:labelCenterPoint withFont:font];
        }
        
        UIGraphicsPopContext();
    }
    
    if (0 != self.progress)
    {
        endAngle = (CGFloat) (- M_PI_2 + self.progress * 2 * M_PI);
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockWise];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
}

- (void)updateProgressCircle:(float) progressVal totalVal:(float) totalVal
{
    //update progress value
    self.progress = progressVal;
    self.total = totalVal;
    //redraw back & progress circles
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressDelegate)])
    {
        [self.delegate didUpdateProgressView];
        
        if (1 <= progressVal)
        {
            [self.delegate didFisnishProgressView];
        }
    }
}

@end
