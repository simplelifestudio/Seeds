//
//  TorrentDownloadAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TorrentDownloadAgent.h"

#import "CBFileUtils.h"

@interface TorrentDownloadAgent()
{
    NSString* code;
    NSString* downloadPath;
    NSString* fileName;
    NSString* fileFullPath;
}

-(void) computeCode:(Seed*) seed;
-(void) computeDownloadFullPath:(NSString*) path;

@end

@implementation TorrentDownloadAgent

@synthesize delegate = _delegate;

+(NSString*) torrentCode:(Seed *)seed
{
    NSString* code = nil;
    
    if (nil != seed && nil != seed.torrentLink)
    {
        // link sample: http://www.maxp2p.com/link.php?ref=LCOqeYLdky        
        NSRange range = [seed.torrentLink rangeOfString:BASEURL_TORRENTCODE];
        if (0 < range.length)
        {
            code = [seed.torrentLink substringFromIndex:range.length];
        }
    }
    
    return code;
}

+(NSString*) torrentFileName:(Seed*) seed
{
    NSString* fileName = nil;
    
    NSString* code = [TorrentDownloadAgent torrentCode:seed];
    if (nil != code && 0 < code.length)
    {
        NSMutableString* mutableStr = [NSMutableString string];
        [mutableStr appendString:code];
        [mutableStr appendString:FILE_EXTENDNAME_DOT_TORRENT];
        fileName = mutableStr;
    }
    
    return fileName;
}

+(NSString*) torrentFileFullPath:(Seed *)seed
{
    NSString* fullPath = nil;
    
    if (nil != seed)
    {
        NSString* downloadPath = [TransmissionModule downloadTorrentsFolderPath];
        
        NSString* fileName = [TorrentDownloadAgent torrentFileName:seed];
        if (nil != fileName && 0 < fileName.length)
        {
            fullPath = [downloadPath stringByAppendingPathComponent:fileName];
        }
    }
    
    return fullPath;
}

-(id) initWithSeed:(Seed*) seed downloadPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        [self computeCode:seed];
        [self computeDownloadFullPath:path];
    }
    
    return self;
}

-(void) computeCode:(Seed*) seed
{
    code = [TorrentDownloadAgent torrentCode:seed];
    fileName = [TorrentDownloadAgent torrentFileName:seed];
}

-(void) computeDownloadFullPath:(NSString*) path
{
    if (nil != path && 0 < path.length)
    {
        downloadPath = path;
    }
    else
    {
        downloadPath = [CBPathUtils documentsDirectoryPath];
    }
    
    if (nil != fileName && 0 < fileName.length)
    {
        fileFullPath = [downloadPath stringByAppendingPathComponent:fileName];
    }
}

-(void) download:(TorrentDownloadSuccessBlock) successBlock failBlock:(TorrentDownloadFailBlock) failBlock
{
    if (nil != code && 0 < code.length)
    {
        NSURL *baseURL = [NSURL URLWithString:BASEURL_TORRENT];
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:code forKey:FORM_ATTRKEY_REF];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_HEADER_FORMDATA];
        
        [client
            postPath:URL_LOADPAGE
            parameters:parameters
            success:successBlock
            failure:failBlock
        ];
    }
    else
    {
        DLog(@"Invalid torrent code.");
    }
}

-(void) downloadWithDelegate:(id<TorrentDownloadAgentDelegate>)delegate
{    
    _delegate = delegate;

    NSURL *baseURL = [NSURL URLWithString:BASEURL_TORRENT];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:code forKey:FORM_ATTRKEY_REF];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_HEADER_FORMDATA];
    
    if ([_delegate respondsToSelector:@selector(torrentDownloadStarted:)])
    {
        [_delegate torrentDownloadStarted:code];
    }
    
    [client
        postPath:URL_LOADPAGE
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if ([_delegate respondsToSelector:@selector(torrentDownloadFinished:)])
            {
                [_delegate torrentDownloadFinished:code];
            }
         
            BOOL flag = [CBFileUtils deleteFile:fileFullPath];
            
            flag = [CBFileUtils createFile:fileFullPath content:responseObject];
            if(flag)
            {
                if ([_delegate respondsToSelector:@selector(torrentSaveFinished:filePath:)])
                {
                    [_delegate torrentSaveFinished:code filePath:fileFullPath];
                }
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(torrentSaveFailed:filePath:)])
                {
                    [_delegate torrentSaveFailed:code filePath:fileFullPath];
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if ([_delegate respondsToSelector:@selector(torrentDownloadFailed:error:)])
            {
                [_delegate torrentDownloadFailed:code error:error];
            }
        }
     ];
}

@end
