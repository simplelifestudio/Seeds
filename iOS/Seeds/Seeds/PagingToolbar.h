//
//  PagingToolbar.h
//  Seeds
//
//  Created by Patrick Deng on 13-6-29.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagingDelegate <NSObject>

@required
-(void) gotoPage:(NSUInteger) pageNum;

@end

@interface PagingToolbar : UIToolbar

@property (strong, nonatomic) id<PagingDelegate> pagingDelegate;

@property (nonatomic) NSUInteger itemCount;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger pageSize;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *firstPageBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevPageBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageNumBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPageBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lastPageBarButton;

- (IBAction)onClickFirstPageBarButton:(id)sender;
- (IBAction)onClickPrevPageBarButton:(id)sender;
- (IBAction)onClickNextPageBarButton:(id)sender;
- (IBAction)onClickLastPageBarButton:(id)sender;

- (NSUInteger) pageCount;
- (NSUInteger) pageStartItemIndex;
- (NSUInteger) pageEndItemIndex;

@end
