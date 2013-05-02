//
//  CircularProgressView.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CircularProgressDelegate;

@interface CircularProgressView : UIView

@property (assign, nonatomic) id <CircularProgressDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;

- (void)updateProgressCircle:(float) progressVal;

@end

@protocol CircularProgressDelegate <NSObject>

- (void)didUpdateProgressView;

@end