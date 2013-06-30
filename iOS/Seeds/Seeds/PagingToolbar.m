//
//  PagingToolbar.m
//  Seeds
//
//  Created by Patrick Deng on 13-6-29.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "PagingToolbar.h"

#define PAGE_SIZE_DEFAULT 10

@interface PagingToolbar()
{
    NSUInteger _pageCount;
    
    UILabel* _pageNumLabel;
}

@end

@implementation PagingToolbar

@synthesize pagingDelegate = _pagingDelegate;

@synthesize firstPageBarButton = _firstPageBarButton;
@synthesize prevPageBarButton = _prevPageBarButton;
@synthesize pageNumBarButton = _pageNumBarButton;
@synthesize nextPageBarButton = _nextPageBarButton;
@synthesize lastPageBarButton = _lastPageBarButton;

@synthesize itemCount = _itemCount;
@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;

-(NSUInteger) pageCount
{
    return _pageCount;
}

- (NSUInteger) pageStartItemIndex
{
    NSUInteger pageStartIndex = _pageSize * (_currentPage - 1);
    return pageStartIndex;
}

- (NSUInteger) pageEndItemIndex
{
    NSUInteger pageEndIndex = _pageSize * _currentPage;
    if (pageEndIndex >= _itemCount + 1)
    {
        pageEndIndex = _itemCount;
    }
    return pageEndIndex;
}

-(void) setCurrentPage:(NSUInteger)currentPage
{
    if (0 < currentPage && currentPage <= _pageCount)
    {
        _currentPage = currentPage;
        
        [self _refreshBarButtonArrayStatus];
        [self _refreshPageNumLabel];
    }
}

-(void) setItemCount:(NSUInteger)itemCount
{
    _itemCount = itemCount;
    
    [self _computePageData];
}

-(void) setPageSize:(NSUInteger)pageSize
{
    _pageSize = pageSize;
    
    [self _computePageData];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setupToolbar];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setupToolbar];
    
    [super awakeFromNib];
}

- (IBAction)onClickFirstPageBarButton:(id)sender
{    
    if (_pagingDelegate)
    {
        NSUInteger targetPageNum = 1;        
        [_pagingDelegate gotoPage:targetPageNum];
    }
}

- (IBAction)onClickPrevPageBarButton:(id)sender
{
    if (_pagingDelegate)
    {
        NSUInteger targetPageNum = (_currentPage > 0) ? _currentPage - 1 : 1;
        [_pagingDelegate gotoPage:targetPageNum];
    }
}

- (IBAction)onClickNextPageBarButton:(id)sender
{
    if (_pagingDelegate)
    {
        NSUInteger targetPageNum = (_currentPage < _pageCount) ? _currentPage + 1 : _pageCount;
        [_pagingDelegate gotoPage:targetPageNum];
    }
}

- (IBAction)onClickLastPageBarButton:(id)sender
{
    if (_pagingDelegate)
    {
        NSUInteger targetPageNum = _pageCount;
        [_pagingDelegate gotoPage:targetPageNum];
    }
}

#pragma mark - Private Methods
- (void) _setupToolbar
{
    _pageSize = PAGE_SIZE_DEFAULT;
    [self _computePageData];
    
    _pageNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    _pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    _pageNumLabel.textColor = [UIColor whiteColor];
    _pageNumLabel.backgroundColor = [UIColor clearColor];
    _pageNumLabel.textAlignment = UITextAlignmentCenter;
    [_pageNumBarButton setCustomView:_pageNumLabel];
    
    [self _refreshPageNumLabel];
}

- (void) _refreshPageNumLabel
{
    NSMutableString* _pageNumStr = [NSMutableString string];
    
    [_pageNumStr appendString:[NSString stringWithFormat:@"%d", _currentPage]];
    [_pageNumStr appendString:@" / "];
    [_pageNumStr appendString:[NSString stringWithFormat:@"%d", _pageCount]];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        _pageNumLabel.text = _pageNumStr;    
    });
}

- (void) _computePageData
{
    _pageCount = _itemCount / _pageSize + ((0 < (_itemCount % _pageSize)) ? 1 : 0);
    _pageCount = (0 == _pageCount) ? 1 : _pageCount;
    [self setCurrentPage:1];
}

- (void) _refreshBarButtonArrayStatus
{
    if (0 < _currentPage && _currentPage <= _pageCount)
    {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (_currentPage == 1)
            {
                [_firstPageBarButton setEnabled:NO];
                [_prevPageBarButton setEnabled:NO];

                if (_currentPage == _pageCount)
                {
                    [_nextPageBarButton setEnabled:NO];
                    [_lastPageBarButton setEnabled:NO];
                }
                else
                {
                    [_nextPageBarButton setEnabled:YES];
                    [_lastPageBarButton setEnabled:YES];
                }
            }
            else if (_currentPage == _pageCount)
            {
                [_nextPageBarButton setEnabled:NO];
                [_lastPageBarButton setEnabled:NO];
                
                if (_currentPage == 1)
                {
                    [_firstPageBarButton setEnabled:NO];
                    [_prevPageBarButton setEnabled:NO];
                }
                else
                {
                    [_firstPageBarButton setEnabled:YES];
                    [_prevPageBarButton setEnabled:YES];
                }
            }
            else
            {
                [_firstPageBarButton setEnabled:YES];
                [_prevPageBarButton setEnabled:YES];
                [_nextPageBarButton setEnabled:YES];
                [_lastPageBarButton setEnabled:YES];
            }        
        });
    }
}

@end
