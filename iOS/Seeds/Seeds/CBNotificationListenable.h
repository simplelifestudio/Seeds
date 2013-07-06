//
//  CBNotificationListenable.h
//  Seeds
//
//  Created by Patrick Deng on 13-7-6.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CBNotificationListenable <NSObject>

-(void) listenNotifications;

-(void) unlistenNotifications;

-(void) onNotificationReceived:(NSNotification*) notification;

@end
