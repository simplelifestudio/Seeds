//
//  CaculatorHelpViewController.m
//  dbm-watt
//
//  Created by Patrick Deng on 13-2-24.
//  Copyright (c) 2013年 Code Animal. All rights reserved.
//

#import "HelpViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface HelpViewController ()
{
    UserDefaultsModule* _userDefaults;
}

@end

@implementation HelpViewController

@synthesize helpView = _helpView;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

@synthesize exitButton = _exitButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setupViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setHelpView:nil];

    [self setExitButton:nil];
    [super viewDidUnload];
}

- (IBAction)onClickExitButton:(id)sender
{
    [self _exit];
}

-(IBAction)pageTurn:(UIPageControl *)sender
{
    [self _activateDisplayTimer:FALSE];
    
    int pageNum = _pageControl.currentPage;
    CGSize pageSize = _scrollView.frame.size;
    CGRect rect = CGRectMake((pageNum) * pageSize.width, 0, pageSize.width, pageSize.height);
    [_scrollView scrollRectToVisible:rect animated:TRUE];
    
    [self _refreshPageControlButtonsStatus];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // repeat scrolling
    // N/A
    
    // single round scrolling
    if (currentPage < imageArray.count)
    {
        _pageControl.currentPage = currentPage;
    }
    else
    {
        _pageControl.currentPage = imageArray.count;
    }
    
    [self _refreshPageControlButtonsStatus];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _activateDisplayTimer:FALSE];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self _activateDisplayTimer:TRUE];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - Private Methods

-(void)_setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    
    [self _initArray];
    [self _configHelpViewUI];
    [self _refreshPageControlButtonsStatus];
}

-(void)_initArray
{
    UIImage* helpImage1 = [UIImage imageNamed:@"help_01.jpg"];
    UIImage* helpImage2 = [UIImage imageNamed:@"help_02.jpg"];
    UIImage* helpImage3 = [UIImage imageNamed:@"help_03.jpg"];
    UIImage* helpImage4 = [UIImage imageNamed:@"help_04.jpg"];
    UIImage* helpImage5 = [UIImage imageNamed:@"help_05.jpg"];
    UIImage* helpImage6 = [UIImage imageNamed:@"help_06.jpg"];
    
    imageArray = [NSArray arrayWithObjects: helpImage1, helpImage2, helpImage3, helpImage4, helpImage5, helpImage6, nil];
}

-(void)_configHelpViewUI
{
    _scrollView.delegate = self;
    
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;  
    
    // fill images
    for (int i = 0; i < imageArray.count; i++)
    {
        UIImageView *subImageView = [[UIImageView alloc] initWithImage:[imageArray objectAtIndex:i]];
        subImageView.frame = CGRectMake(width * i, 0, width, height);
        subImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview: subImageView];
    }
    
    // set the whole scrollView's size
    [_scrollView setContentSize:CGSizeMake(width * imageArray.count, height)];
    [_helpView addSubview:_scrollView];
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, width, height) animated:NO];
    // set page control UI attributes
    _pageControl.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _pageControl.alpha = 1.0;
    _pageControl.numberOfPages = imageArray.count;
    [_pageControl setBounds:CGRectMake(0, 0, 18 * (_pageControl.numberOfPages + 1), 18)];
    [_pageControl.layer setCornerRadius:8];
    _pageControl.currentPage = 0;
    _pageControl.enabled = YES;
    [_helpView addSubview:_pageControl];
    [_pageControl addTarget:self action:@selector(pageTurn:)forControlEvents:UIControlEventValueChanged];
    
    _exitButton.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    [_helpView addSubview:_exitButton];
    
    [self _registerGestureRecognizers];
    
    // set auto display timer
    [self _activateDisplayTimer:TRUE];
}

- (void) _registerGestureRecognizers
{
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [_helpView addGestureRecognizer:tapRecognizer];
}

- (void)_handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self _exit];
}

-(void)_scrollToNextPage:(id)sender
{
    // repeat scrolling
    //    int pageNum = _pageControl.currentPage;
    //    CGSize viewSize = _scrollView.frame.size;
    //
    //    if (pageNum == imageArray.count - 1)
    //    {
    //        CGRect newRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    //        [_scrollView scrollRectToVisible:newRect animated:NO];
    //    }
    //    else
    //    {
    //        pageNum++;
    //        CGRect rect = CGRectMake(pageNum * viewSize.width, 0, viewSize.width, viewSize.height);
    //        [_scrollView scrollRectToVisible:rect animated:TRUE];
    //    }
    
    // single round scrolling
    CGSize pageSize = _scrollView.frame.size;
    int pageNum = _pageControl.currentPage;
    if (pageNum == imageArray.count - 1)
    {
        [displayTimer invalidate];
    }
    else
    {
        pageNum++;
        CGRect rect = CGRectMake(pageNum * pageSize.width, 0, pageSize.width, pageSize.height);
        [_scrollView scrollRectToVisible:rect animated:TRUE];
    }
    
    [self _refreshPageControlButtonsStatus];
}

-(void) _exit
{
    BOOL isAppLaunchedBefore = [_userDefaults isAppLaunchedBefore];
    if (!isAppLaunchedBefore)
    {
        [_userDefaults recordAppLaunchedBefore];

        [self performSegueWithIdentifier:SEGUE_ID_HELP2NAVIGATION sender:self];
    }
    else
    {
        [self dismissViewControllerAnimated:TRUE completion:^{}];
    }
}

-(void)_scrollToPrevPage:(id)sender
{
    // single round scrolling
    CGSize pageSize = _scrollView.frame.size;
    int pageNum = _pageControl.currentPage;
    if (pageNum == 0)
    {
        [displayTimer invalidate];
    }
    else
    {
        pageNum--;
        CGRect rect = CGRectMake(pageNum * pageSize.width, 0, pageSize.width, pageSize.height);
        [_scrollView scrollRectToVisible:rect animated:TRUE];
    }
    
    [self _refreshPageControlButtonsStatus];
}

-(void) _activateDisplayTimer:(BOOL) activate
{
    if (activate)
    {
        displayTimer = [NSTimer scheduledTimerWithTimeInterval:HELPSCREEN_DISPLAY_SECONDS target:self selector:@selector(_scrollToNextPage:) userInfo:nil repeats:YES];
    }
    else
    {
        if (displayTimer.isValid)
        {
            [displayTimer invalidate];
        }
    }
}

-(void) _refreshPageControlButtonsStatus
{
    NSInteger pageNum = _pageControl.currentPage;
    if (0 == pageNum)
    {
        [_exitButton setHidden:YES];
    }
    else if(pageNum == imageArray.count - 1)
    {
        [_exitButton setHidden:NO];
    }
    else
    {
        [_exitButton setHidden:YES];
    }
}

@end
