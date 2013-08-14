//
//  SecurityModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SecurityModule.h"
#import "CBSecurityUtils.h"

@implementation SecurityModule

SINGLETON(UserDefaultsModule)

-(void) initModule
{
    [self setModuleIdentity:NSLocalizedString(@"Security Module", nil)];
    [self.serviceThread setName:NSLocalizedString(@"Security Module Thread", nil)];
    [self setKeepAlive:FALSE];
}

-(void) releaseModule
{
    [super releaseModule];
}

-(void) startService
{
    DDLogVerbose(@"Module:%@ is started.", self.moduleIdentity);
    
    [super startService];
}

-(void) processService
{
    MODULE_DELAY
    
//    NSString* securityKey = @"20130801";
//    NSString* plainText = @"{\"id\":\"AlohaRequest\",\"body\":{\"content\":\"我是中国人\"}}";
//    NSString* encryptedText = [CBSecurityUtils encryptByDESAndEncodeByBase64:plainText key:securityKey];
//    encryptedText = @"Qi8iv15nOLgBASPRS1cce7BWZ9TyNb7ag0e+UzfibcTYg+0+BXnfLpYzM5t0 4K6e0s/zwpsu3RBdcV50MTqv/w==";
//    NSString* decryptedText = [CBSecurityUtils decryptByDESAndDecodeByBase64:encryptedText key:securityKey];
//    DDLogWarn(@"密匙：%@", securityKey);
//    DDLogWarn(@"原文：%@", plainText);
//    DDLogWarn(@"密文：%@", encryptedText);
//    DDLogWarn(@"解密：%@", decryptedText);
}

@end
