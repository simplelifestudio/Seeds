//
//  WarningViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "WarningViewController.h"

@interface WarningViewController ()
{
    NSUInteger _countdownSeconds;
    NSTimer* _timer;
    
    UINavigationBar* _navigationBar;
}

@end

@implementation WarningViewController

@synthesize warningTextView = _warningTextView;
@synthesize countdownLabel = _countdownLabel;
@synthesize agreeButton = _agreeButton;
@synthesize declineButton = _declineButton;
@synthesize warningNavigationItem = _warningNavigationItem;

@synthesize warningDelegate = _warningDelegate;

@synthesize warningId = _warningId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self _setupViewController];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [self _setupViewController];    
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setWarningTextView:nil];
    [self setCountdownLabel:nil];
    [self setAgreeButton:nil];
    [self setDeclineButton:nil];
    [self setWarningNavigationItem:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];

    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self _clockStart];
}

- (void) setWarningText:(NSString*) text
{
    [_warningTextView setText:text];
}

- (void) setCountdownSeconds:(NSUInteger) seconds
{
    if (0 < seconds)
    {
        _countdownSeconds = seconds;
        [_countdownLabel setText:[NSString stringWithFormat:@"%d", _countdownSeconds]];        
    }
}

- (void) setAgreeButtonVisible:(BOOL) visible
{
    [_agreeButton setHidden:!visible];
}

- (void) setDeclineButtonVisible:(BOOL) visible
{
    [_declineButton setHidden:!visible];
}

#pragma mark - IBAtions

- (IBAction)onClickAgreeButton:(id)sender
{
    if (_warningDelegate)
    {
        [_warningDelegate agreeButtonClicked:_warningId];
    }
    
    [self _clockCancel];    
}

- (IBAction)onClickDeclineButton:(id)sender
{
    if (_warningDelegate)
    {
        [_warningDelegate declineButtonClicked:_warningId];
    }
    
    [self _clockCancel];    
}

#pragma mark - Private Methods

- (void) _setupViewController
{
    _countdownSeconds = 0;
    
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEIGHT_NAVIGATION_BAR)];
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_navigationBar setItems:@[_warningNavigationItem]];
    
    [self.view addSubview:_navigationBar];
    
    [self _formatFlatUI];
}

- (void) _formatFlatUI
{
    _warningTextView.textColor = COLOR_TEXT_INFO;
    _warningTextView.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    self.view.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    [GUIStyle formatFlatUINavigationBar:_navigationBar];
    
    [GUIStyle formatFlatUIButton:_agreeButton buttonColor:FLATUI_COLOR_BUTTON shadowColor:FLATUI_COLOR_BUTTON_SHADOW shadowHeight:0 cornerRadius:3 titleColor:FLATUI_COLOR_BUTTON_TEXT highlightedTitleColor:FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED];
    [GUIStyle formatFlatUIButton:_declineButton buttonColor:FLATUI_COLOR_BUTTON shadowColor:FLATUI_COLOR_BUTTON_SHADOW shadowHeight:0 cornerRadius:3 titleColor:FLATUI_COLOR_BUTTON_TEXT highlightedTitleColor:FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED];
}

- (void) _clockStart
{
    [self _clockCancel];
    
    NSTimeInterval interval = 1.0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(_clockClick) userInfo:nil repeats:YES];
}

- (void) _clockClick
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [_countdownLabel setText:[NSString stringWithFormat:@"%d", _countdownSeconds]];
    });
    
    _countdownSeconds--;
    
    if (0 == _countdownSeconds && _warningDelegate)
    {
        [_warningDelegate countdownFinished:_warningId];
    }
}

- (void) _clockCancel
{
    if (nil != _timer)
    {
        [_timer invalidate];        
    }
}

@end
