//
//  SecurityModule.m
//  Seeds
//
//  Created by Patrick Deng on 13-8-14.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SecurityModule.h"

#import "CBSecurityUtils.h"
#import "CBGZipUtils.h"

#import "CBFileUtils.h"

#import "CBPathUtils.h"

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
    
    [self _testDESAndBase64AndGZip];
}

-(void) _testDESAndBase64AndGZip
{
//    NSString* securityKey = @"20130801";
    
//    NSString* plainText = @"{\"id\":\"AlohaRequest\",\"body\":{\"content\":\"我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~我勒个去~好Good\"}}";
//    NSString* encryptedText = [CBSecurityUtils encryptByDESAndEncodeByBase64:plainText key:securityKey];
//    NSString* decryptedText = [CBSecurityUtils decryptByDESAndDecodeByBase64:encryptedText key:securityKey];
//    DDLogWarn(@"密匙：%@", securityKey);
//    DDLogWarn(@"原文：%@", plainText);
//    DDLogWarn(@"密文：%@", encryptedText);
//    DDLogWarn(@"解密：%@", decryptedText);
//
//    DDLogWarn(@"#########");
    
//    NSData* plainData = [encryptedText dataUsingEncoding:NSUTF8StringEncoding];
//    NSData* zippedData = [CBGZipUtils gzipData:plainData];
//    NSData* unzippedData = [CBGZipUtils uncompressZippedData:zippedData];
//    DDLogWarn(@"原文：%@", plainText);
//    DDLogWarn(@"原文长度：%d", plainData.length);
//    DDLogWarn(@"压缩：%@", @"压缩字符串不可读");
//    DDLogWarn(@"压缩长度：%d", zippedData.length);
//    DDLogWarn(@"解压：%@", [NSString stringWithUTF8String:[unzippedData bytes]]);
//    DDLogWarn(@"解压长度：%d", unzippedData.length);
//    
//    DDLogWarn(@"$$$$$$$$$");
    
//    NSString* gzFilePath = [[NSBundle mainBundle] pathForResource:@"testGZip" ofType:@"gz"];
//    NSData* zippedData = [CBFileUtils dataFromFile:gzFilePath];
//    NSData* unzippedData = [CBGZipUtils uncompressZippedData:zippedData];
//
//    NSString* encryptedText = [[NSString alloc] initWithData:unzippedData encoding:NSUTF8StringEncoding];
//    NSString* decryptedText = [CBSecurityUtils decryptByDESAndDecodeByBase64:encryptedText key:securityKey];
//    DDLogWarn(@"解压解码解密：%@", decryptedText);
}

@end
