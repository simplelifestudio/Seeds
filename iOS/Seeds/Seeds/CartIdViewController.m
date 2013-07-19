//
//  CartIdViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CartIdViewController.h"

#define _HUD_DISPLAY 1

@interface CartIdViewController () <UITextViewDelegate>
{
    UserDefaultsModule* _userDefaults;
    
    GUIModule* _guiModule;
    
    CommunicationModule* _commModule;
    ServerAgent* _serverAgent;
    
    BOOL _isSaveNeed;
    
    CGRect originalContentViewFrame;
}

@end

@implementation CartIdViewController

@synthesize textView = _textView;
@synthesize clipboardButton = _clipboardButton;
@synthesize changeButton = _changeButton;
@synthesize editButton = _editButton;

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
    [self _refereshTextView];
 
    [self _resetEditButton];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString* cartId = [_userDefaults cartId];
    if (nil == cartId || 0 == cartId.length)
    {
        [self _renewCartId];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [self _setupViewController];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setChangeButton:nil];
    [self setClipboardButton:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onClickClipboardButton:(id)sender
{
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    HUD.labelText = NSLocalizedString(@"Copied to Clipboard", nil);
    [HUD showAnimated:YES whileExecutingBlock:^(){
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = _textView.text;
        
        [NSThread sleepForTimeInterval:_HUD_DISPLAY];
    }];
}

- (IBAction)onClickChangeButton:(id)sender
{
    [self _renewCartId];
    
    [self _resetEditButton];
}

- (IBAction)onClickEditButton:(id)sender
{
    NSString* title = _editButton.titleLabel.text;
    if ([title isEqualToString:NSLocalizedString(@"Save", nil)])
    {
        [self _saveCartId];
        [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Cancel", nil)])
    {
        [self _cancelEditCartId];
        [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];        
    }
    else if ([title isEqualToString:NSLocalizedString(@"Edit", nil)])
    {
        [self _startEditCartId];
        [_editButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];        
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString* oldCartId = [_userDefaults cartId];
    NSString* oldCartFullLink = [self _composeFullCartLink:oldCartId];
    
    if (![oldCartFullLink isEqualToString:textView.text])
    {
        _isSaveNeed = YES;
        [_editButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    }
    else
    {
        _isSaveNeed = NO;
        [_editButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Private Methods

-(void) _resetEditButton
{
    [self _cancelEditCartId];
    [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
}

-(void) _saveCartId
{
    NSString* fullCartLink = _textView.text;
    NSString* cartId = [self _decomposeCartIdFromFullCartLink:fullCartLink];
    
    [_userDefaults setCartId:cartId];
    
    [_textView setEditable:NO];
    _textView.backgroundColor = COLOR_BACKGROUND;
    _isSaveNeed = NO;
}

-(void) _cancelEditCartId
{
    NSString* cartId = [_userDefaults cartId];
    _textView.text = [self _composeFullCartLink:cartId];
    
    [_textView setEditable:NO];
    _textView.backgroundColor = COLOR_BACKGROUND;
    _isSaveNeed = NO;
}

-(void) _startEditCartId
{
    [_textView setEditable:YES];
    [_textView becomeFirstResponder];
    _textView.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
}

-(void) _setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    _guiModule = [GUIModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _serverAgent = _commModule.serverAgent;
    
    _isSaveNeed = NO;
    
    _textView.delegate = self;
    
    originalContentViewFrame = self.view.frame;
    
    [self _registerGestureRecognizers];
    
//    [self registerForKeyboardNotifications];
}

-(void) _refereshTextView
{
    NSString* cartId = [_userDefaults cartId];
    
    NSString* fullCartLink = [self _composeFullCartLink:cartId];
    _textView.text = fullCartLink;
}

-(NSString*) _composeFullCartLink:(NSString*) cartId
{
    NSMutableString* str = [NSMutableString string];
    
    if (nil != cartId && 0 < cartId.length)
    {
        [str appendString:BASEURL_SEEDSSERVER];
        [str appendString:REMOTEPATH_CARTSERVICE];
        [str appendString:@"?cartId="];
        [str appendString:cartId];
    }
    
    return str;
}

-(NSString*) _decomposeCartIdFromFullCartLink:(NSString*) fullCartLink
{
    NSString* cartId = nil;
    
    if (nil != fullCartLink && 0 < fullCartLink.length)
    {
        NSMutableString* baseStr = [NSMutableString string];
        [baseStr appendString:BASEURL_SEEDSSERVER];
        [baseStr appendString:REMOTEPATH_CARTSERVICE];
        [baseStr appendString:@"?cartId="];
        cartId = [CBStringUtils replaceSubString:@"" oldSubString:baseStr string:fullCartLink];
    }
    
    return cartId;
}

-(void) _renewCartId
{
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    [HUD showAnimated:YES
        whileExecutingBlock:^()
        {
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = NSLocalizedString(@"Applying", nil);
            NSString* cartId = [_serverAgent newCartId];
            if (nil != cartId && 0 < cartId.length)
            {
                [_userDefaults setCartId:cartId];
                [CBAppUtils asyncProcessInMainThread:^(){
                    [self _refereshTextView];
                }];
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Apply Successfully", nil);
            }
            else
            {
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Apply Failed", nil);
            }
            
            [NSThread sleepForTimeInterval:_HUD_DISPLAY];
        }
        completionBlock:^()
        {
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = nil;
            HUD.detailsLabelText = nil;
        }
    ];
}

- (void) _registerGestureRecognizers
{    
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeRight:(UISwipeGestureRecognizer*) gestureRecognizer
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWasShow:)
                                                name:UIKeyboardDidShowNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWillBeHidden:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter  defaultCenter] removeObserver:self
                                                   name:UIKeyboardDidShowNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification
{
    
    // 取得键盘的frame，注意，因为键盘在window的层面弹出来的，所以它的frame坐标也是对应window窗口的。
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGPoint endOrigin = endRect.origin;
    // 把键盘的frame坐标系转换到与UITextView一致的父view上来。
    if ([UIApplication sharedApplication].keyWindow && _textView.superview) {
        endOrigin = [self.view.superview convertPoint:endRect.origin fromView:[UIApplication sharedApplication].keyWindow];
    }
    
    CGFloat adjustHeight = originalContentViewFrame.origin.y + originalContentViewFrame.size.height;
    // 根据相对位置调整一下大小，自己画图比划一下就知道为啥要这样计算。
    // 当然用其他的调整方式也是可以的，比如取UITextView的orgin，origin到键盘origin之间的高度作为UITextView的高度也是可以的。
    adjustHeight -= endOrigin.y;
    if (adjustHeight > 0) {
        
        CGRect newRect = originalContentViewFrame;
        newRect.size.height -= adjustHeight;
        [UIView beginAnimations:nil context:nil];
        self.view.frame = newRect;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    // 恢复原理的大小
    [UIView beginAnimations:nil context:nil];
    self.view.frame = originalContentViewFrame;
    [UIView commitAnimations];
}

@end
