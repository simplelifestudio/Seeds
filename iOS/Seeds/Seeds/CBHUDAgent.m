//
//  CBHUDAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBHUDAgent.h"

#import "MBProgressHUD.h"

#define QUEUE_ID_HUD "Seeds_Queue_HUD"



@interface CBHUDAgent()
{
    dispatch_queue_t _hudQueue;
    MBProgressHUD* _HUD;
    
    UIView* _HUDView;
}

@end

@implementation CBHUDAgent

-(id) initWithUIView:(UIView*) view
{
    self = [super init];
    if (self)
    {
        [self _setupInstance];
        [self attachToView:view];
    }
    return self;
}

-(void) showHUD:(NSString*) majorStauts minorStatus:(NSString*) minorStatus delay:(NSInteger)seconds;
{
    MBProgressHUD* HUD = [self sharedHUD];
    
    dispatch_sync(_hudQueue, ^(){
        HUD.labelText = majorStauts;
        if (minorStatus)
        {
            HUD.detailsLabelText = minorStatus;
        }
        else
        {
            HUD.detailsLabelText = nil;
        }
        
        [self _showHUD:seconds];
    });
}

-(void) attachToView:(UIView*) view
{
    _HUDView = view;
}

-(MBProgressHUD*) sharedHUD
{
    _HUD = [MBProgressHUD showHUDAddedTo:_HUDView animated:YES];
    
    _HUD.minSize = HUD_CENTER_SIZE;
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = nil;
    _HUD.detailsLabelText = nil;
    
    return _HUD;
}

- (void) releaseResources
{
    dispatch_release(_hudQueue);
}

#pragma mark - Private Methods

-(void) _setupInstance
{
    [self _setupHUD];
    
    _hudQueue = dispatch_queue_create(QUEUE_ID_HUD, DISPATCH_QUEUE_SERIAL);
}

-(void) _setupHUD
{
    UIWindow* keyWindow = [CBUIUtils getKeyWindow];
    _HUD = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    _HUD.mode = MBProgressHUDModeText;
    _HUD.minSize = HUD_CENTER_SIZE;
}

-(void) _showHUD:(NSUInteger) seconds
{
    [CBAppUtils asyncProcessInMainThread:^(){
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:seconds];
    }];
}

@end
