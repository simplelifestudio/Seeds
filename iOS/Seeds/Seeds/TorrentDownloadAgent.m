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
    Seed* _seed;
    
    NSString* _code;
    NSString* _downloadPath;
    NSString* _fileName;
    NSString* _fileFullPath;
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
    
    fileName = [TorrentDownloadAgent torrentFileNameBySeedLocalId:seed.localId];
    
    return fileName;
}

+(NSString*) torrentFileNameBySeedLocalId:(NSInteger) localId
{
    NSString* fileName = nil;
    
    NSMutableString* mutableStr = [NSMutableString string];
//    [mutableStr appendString:FILE_PREFIXNAME_SEED];
    [mutableStr appendString:[NSString stringWithFormat:@"%d", localId]];
    [mutableStr appendString:FILE_EXTENDNAME_DOT_TORRENT];
    fileName = mutableStr;
    
    return fileName;
}

+(NSString*) torrentFileFullPath:(Seed *)seed
{
    NSString* fullPath = nil;
    
    if (nil != seed)
    {
        NSString* downloadPath = [SeedsDownloadAgent downloadPath];
        NSString* downloadPathWithDate = [downloadPath stringByAppendingPathComponent:seed.publishDate];
        
        NSString* fileName = [TorrentDownloadAgent torrentFileName:seed];
        if (nil != fileName && 0 < fileName.length)
        {
            fullPath = [downloadPathWithDate stringByAppendingPathComponent:fileName];
        }
    }
    
    return fullPath;
}

+(NSString*) torrentFileFullPathBySeedLocalId:(NSInteger) localId
{
    NSString* fullPath = nil;
    
    return fullPath;
}

-(id) initWithSeed:(Seed*) seed downloadPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _seed = seed;
        [self computeCode:seed];
        [self computeDownloadFullPath:path];
    }
    
    return self;
}

-(void) computeCode:(Seed*) seed
{
    _code = [TorrentDownloadAgent torrentCode:seed];
    _fileName = [TorrentDownloadAgent torrentFileName:seed];
}

-(void) computeDownloadFullPath:(NSString*) path
{
    if (nil != path && 0 < path.length)
    {
        _downloadPath = path;
    }
    else
    {
        _downloadPath = [Environment torrentsDirPath];
    }
    
    if (nil != _fileName && 0 < _fileName.length)
    {
        _fileFullPath = [_downloadPath stringByAppendingPathComponent:_fileName];
    }
}

-(void) download:(TorrentDownloadSuccessBlock) successBlock failBlock:(TorrentDownloadFailBlock) failBlock
{
    if (nil != _seed && 0 < _seed.localId)
    {
        NSURL *baseURL = [NSURL URLWithString:BASEURL_TORRENT];
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:_code forKey:FORM_ATTRKEY_REF];
        
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
        DDLogError(@"Invalid torrent code.");
    }
}

-(void) downloadWithDelegate:(id<TorrentDownloadAgentDelegate>)delegate
{    
    _delegate = delegate;

    NSURL *baseURL = [NSURL URLWithString:BASEURL_TORRENT];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:_code forKey:FORM_ATTRKEY_REF];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_HEADER_FORMDATA];
    
    if (_delegate)
    {
        [_delegate torrentDownloadStarted:_seed];
    }
    
    [client
        postPath:URL_LOADPAGE
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {            
            if (_delegate)
            {
                [_delegate torrentDownloadFinished:_seed];
            }
         
            [CBFileUtils deleteFile:_fileFullPath];
            BOOL flag = [CBFileUtils createFile:_fileFullPath content:responseObject];
            if(flag)
            {
                if (_delegate)
                {
                    [_delegate torrentSaveFinished:_seed filePath:_fileFullPath];
                }
            }
            else
            {
                if (_delegate)
                {
                    [_delegate torrentSaveFailed:_seed filePath:_fileFullPath];
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (_delegate)
            {
                [_delegate torrentDownloadFailed:_seed error:error];
            }
        }
     ];
}

@end
