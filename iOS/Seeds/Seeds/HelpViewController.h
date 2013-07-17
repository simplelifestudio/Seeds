//
//  CaculatorHelpViewController.h
//  dbm-watt
//
//  Created by Patrick Deng on 13-2-24.
//  Copyright (c) 2013年 Code Animal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray *imageArray;
    NSTimer *displayTimer;
}

@property (weak, nonatomic) IBOutlet UIView *helpView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)onClickExitButton:(id)sender;
- (IBAction)pageTurn:(UIPageControl *)sender;

@end
