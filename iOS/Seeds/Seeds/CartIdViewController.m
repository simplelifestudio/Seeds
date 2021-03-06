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
    
    UIBarButtonItem* _editBarButtonItem;
}

@end

@implementation CartIdViewController

@synthesize textView = _textView;
@synthesize clipboardButton = _clipboardButton;
@synthesize changeButton = _changeButton;

+(NSString*) composeFullCartLink:(NSString*) cartId
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

+(NSString*) decomposeCartIdFromFullCartLink:(NSString*) fullCartLink
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
    __block UIPasteboard *pboard = nil;
    [HUD showAnimated:YES whileExecutingBlock:^(){
        pboard = [UIPasteboard generalPasteboard];
        [NSThread sleepForTimeInterval:_HUD_DISPLAY];
    }];
    
    NSString* cartId = _textView.text;
    NSString* cartFullLink = [CartIdViewController composeFullCartLink:cartId];
    
    pboard.string = cartFullLink;
}

- (IBAction)onClickChangeButton:(id)sender
{
    [self _renewCartId];
    
    [self _resetEditButton];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString* oldCartId = [_userDefaults cartId];
    NSString* oldCartFullLink = [CartIdViewController composeFullCartLink:oldCartId];
    
    if (![oldCartFullLink isEqualToString:textView.text])
    {
        _isSaveNeed = YES;
        [_editBarButtonItem setTitle:NSLocalizedString(@"Save", nil)];
    }
    else
    {
        _isSaveNeed = NO;
        [_editBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:STR_NEWLINE])
    {
        [textView resignFirstResponder];

        if (_isSaveNeed)
        {
            [self _saveCartId];
        }
        else
        {
            [self _cancelEditCartId];
        }
        [_editBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
        
        return NO;
    }
    
    if(0 == [text length])
    {
        return YES;
    }
    if(CARTID_MAX_LENGTH <= ([textView.text length] + range.length))
    {
        MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
        HUD.labelText = NSLocalizedString(@"Length Limited", nil);
        [HUD showAnimated:YES whileExecutingBlock:^(){
            [NSThread sleepForTimeInterval:_HUD_DISPLAY];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Private Methods

-(void) _resetEditButton
{
    [self _cancelEditCartId];
    [_editBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
}

-(void) _saveCartId
{
    NSString* cartId = _textView.text;
    
    [_userDefaults setCartId:cartId];
    
    [_textView setEditable:NO];
    _textView.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
    _isSaveNeed = NO;
    
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    HUD.labelText = NSLocalizedString(@"Saved", nil);
    [HUD showAnimated:YES whileExecutingBlock:^(){
        [NSThread sleepForTimeInterval:_HUD_DISPLAY];
    }];
}

-(void) _cancelEditCartId
{
    NSString* cartId = [_userDefaults cartId];
    _textView.text = cartId;
    
    [_textView setEditable:NO];
    _textView.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    _isSaveNeed = NO;
}

-(void) _startEditCartId
{
    [_textView setEditable:YES];
    [_textView becomeFirstResponder];
}

-(void) _setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    _guiModule = [GUIModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _serverAgent = _commModule.serverAgent;
    
    _isSaveNeed = NO;
    
    _textView.delegate = self;
    _textView.keyboardType = UIKeyboardTypeASCIICapable;
    _textView.returnKeyType = UIReturnKeyDone;
    
    [self _formatFlatUI];
    
    [self _setupBarButtonItems];
    
    [self _registerGestureRecognizers];
}

-(void) _formatFlatUI
{
    _textView.textColor = COLOR_TEXT_INFO;
    _textView.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    self.view.backgroundColor = FLATUI_COLOR_VIEW_BACKGROUND;
    
    [GUIStyle formatFlatUIButton:_clipboardButton buttonColor:FLATUI_COLOR_BUTTON shadowColor:FLATUI_COLOR_BUTTON_SHADOW shadowHeight:0 cornerRadius:3 titleColor:FLATUI_COLOR_BUTTON_TEXT highlightedTitleColor:FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED];
    [GUIStyle formatFlatUIButton:_changeButton buttonColor:FLATUI_COLOR_BUTTON shadowColor:FLATUI_COLOR_BUTTON_SHADOW shadowHeight:0 cornerRadius:3 titleColor:FLATUI_COLOR_BUTTON_TEXT highlightedTitleColor:FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED];
}

-(void) _refereshTextView
{
    NSString* cartId = [_userDefaults cartId];
    
    _textView.text = cartId;
}

-(void) _renewCartId
{
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    [HUD showAnimated:YES
        whileExecutingBlock:^()
        {
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = NSLocalizedString(@"Applying", nil);
            
            NSString* cartId = nil;
            
            JSONMessage* responseMessage = [_serverAgent newCartIdRequest];
            if ([JSONMessage isTimeoutResponseMessage:responseMessage])
            {
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Communication Timeout", nil);
            }
            else if ([JSONMessage isErrorResponseMessage:responseMessage])
            {
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Error Response Message", nil);
            }
            else
            {
                if ([responseMessage.command isEqualToString:JSONMESSAGE_COMMAND_SEEDSTOCARTRESPONSE])
                {
                    NSDictionary* contentDic = responseMessage.body;
                    NSDictionary* bodyDic = [contentDic objectForKey:JSONMESSAGE_KEY_BODY];
                    cartId = [bodyDic objectForKey:JSONMESSAGE_KEY_CARTID];
                    
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
                }
            }
            
            [NSThread sleepForTimeInterval:_HUD_DISPLAY];
        }
        completionBlock:^()
        {

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

- (void)_registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)_unregisterForKeyboardNotifications
{
    [[NSNotificationCenter  defaultCenter] removeObserver:self
                                                   name:UIKeyboardDidShowNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:nil];
}

- (void) _setupBarButtonItems
{
    _editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(_onClickEditBarButtonItem)];
        
    self.navigationItem.rightBarButtonItems = @[_editBarButtonItem];
}

- (void) _onClickEditBarButtonItem
{
    NSString* title = _editBarButtonItem.title;
    if ([title isEqualToString:NSLocalizedString(@"Save", nil)])
    {
        [self _saveCartId];
        [_editBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Cancel", nil)])
    {
        [self _cancelEditCartId];
        [_editBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Edit", nil)])
    {
        [self _startEditCartId];
        [_editBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    }
}

@end
