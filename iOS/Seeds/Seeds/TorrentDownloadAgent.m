//
//  TorrentDownloadAgent.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-16.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TorrentDownloadAgent.h"

@interface TorrentDownloadAgent()
{
    NSString* code;
    NSString* downloadPath;
    NSString* fileName;
    NSString* fileFullPath;
}

-(void) computeCodeFromLink:(NSString*) link;
-(void) computeDownloadFullPath:(NSString*) path;

@end

@implementation TorrentDownloadAgent

@synthesize delegate = _delegate;

-(id) initWithTorrentLink:(NSString*) link downloadPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        [self computeCodeFromLink:link];
        [self computeDownloadFullPath:path];
    }
    
    return self;
}

-(void) computeCodeFromLink:(NSString*) link
{
    code = nil;
    
    // link sample: http://www.maxp2p.com/link.php?ref=LCOqeYLdky
    if (nil != link && 0 < link.length)
    {
        NSRange range = [link rangeOfString:BASEURL_TORRENTCODE];
        if (0 < range.length)
        {
            code = [link substringFromIndex:range.length];
            NSMutableString* mutableStr = [NSMutableString string];
            [mutableStr appendString:code];
            [mutableStr appendString:@".torrent"];
            fileName = mutableStr;
        }
    }
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
        [client setDefaultHeader:@"Accept" value:@"multipart/form-data"];
        
        [client
            postPath:@"load.php"
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
    [client setDefaultHeader:@"Accept" value:@"multipart/form-data"];
    
    if ([_delegate respondsToSelector:@selector(torrentDownloadStarted:)])
    {
        [_delegate torrentDownloadStarted:code];
    }
    
    [client
        postPath:@"load.php"
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if ([_delegate respondsToSelector:@selector(torrentDownloadFinished:)])
            {
                [_delegate torrentDownloadFinished:code];
            }
         
            NSFileManager * fm = [NSFileManager defaultManager];
            BOOL flag = [fm removeItemAtPath:fileFullPath error:nil];
            flag = [fm createFileAtPath:fileFullPath contents:responseObject attributes:nil];
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
