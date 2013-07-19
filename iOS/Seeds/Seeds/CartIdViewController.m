//
//  CartIdViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CartIdViewController.h"

#define _HUD_DISPLAY 1

@interface CartIdViewController ()
{
    UserDefaultsModule* _userDefaults;
    
    GUIModule* _guiModule;
    
    CommunicationModule* _commModule;
    ServerAgent* _serverAgent;
}

@end

@implementation CartIdViewController

@synthesize textView = _textView;
@synthesize clipboardButton = _clipboardButton;
@synthesize changeButton = _changeButton;

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
    [CBAppUtils asyncProcessInBackgroundThread:^(){
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = _textView.text;
        
        [_guiModule showHUD:NSLocalizedString(@"Copied to Clipboard", nil) delay:_HUD_DISPLAY];
    }];
}

- (IBAction)onClickChangeButton:(id)sender
{
    [self _renewCartId];
}

#pragma mark - Private Methods

-(void) _setupViewController
{
    _userDefaults = [UserDefaultsModule sharedInstance];
    _guiModule = [GUIModule sharedInstance];
    
    _commModule = [CommunicationModule sharedInstance];
    _serverAgent = _commModule.serverAgent;
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

-(void) _renewCartId
{
    MBProgressHUD* HUD = [_guiModule.HUDAgent sharedHUD];
    [HUD showAnimated:YES
        whileExecutingBlock:^()
        {
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = NSLocalizedString(@"Generating", nil);
            NSString* cartId = [_serverAgent newCartId];
            if (nil != cartId && 0 < cartId.length)
            {
                [_userDefaults setCartId:cartId];
                [CBAppUtils asyncProcessInMainThread:^(){
                    [self _refereshTextView];
                }];
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Generate Successfully", nil);
            }
            else
            {
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"Generate Failed", nil);
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

@end
