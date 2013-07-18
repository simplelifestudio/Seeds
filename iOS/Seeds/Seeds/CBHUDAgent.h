//
//  CBHUDAgent.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HUDDisplayBlock)(NSString* majorStauts, NSString* minorStatus, NSInteger seconds);

@interface CBHUDAgent : NSObject

-(id) initWithUIView:(UIView*) view;

-(void) attachToView:(UIView*) view;
-(void) showHUD:(NSString*) majorStauts minorStatus:(NSString*) minorStatus delay:(NSInteger)seconds;

-(MBProgressHUD*) sharedHUD;

-(void) releaseResources;

@end
