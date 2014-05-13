//
//  SGThreadViewController+Pagination.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 25/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "SGThreadViewController+Pagination.h"
#import "JNAlertView.h"
#import "SGMessage+Service.h"
//#import "HBButton.h"

#define kSGThreadViewPaginationViewHeight 80.0
#define kSGPaginationButtonVerticalPadding 20.0
#define kSGPaginationButtonHorizontalPadding 10.0
#define kSGThreadViewFooterOffset 64.0
#define kSGPaginationButtonTag 8237211

@implementation SGThreadViewController (Pagination)

#pragma mark - Public methods

- (void)setupPaginationInTableView:(UITableView*)tableView
{
    JNLog();
    // table footer view
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, kSGThreadViewFooterOffset + kSGThreadViewPaginationViewHeight)];
    tableFooterView.backgroundColor = JNClearColor;
    tableView.tableFooterView = tableFooterView;
    // table footer view button
    UIButton *paginationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    paginationButton.tag = kSGPaginationButtonTag;
    paginationButton.bounds = CGRectMake(0.0, 0.0,
                                         tableView.frame.size.width - 2 * kSGPaginationButtonHorizontalPadding,
                                         kSGThreadViewPaginationViewHeight - 2 * kSGPaginationButtonVerticalPadding);
    paginationButton.center = CGPointMake(CGRectGetMidX(tableFooterView.bounds), kSGThreadViewFooterOffset + kSGThreadViewPaginationViewHeight/2);
    paginationButton.backgroundColor = JNGrayBackgroundColor;
    [paginationButton setTitle:NSLocalizedString(@"load more", nil) forState:UIControlStateNormal];
    [paginationButton setTitleColor:JNGrayColor forState:UIControlStateNormal];
    [paginationButton setTitleColor:JNWhiteColor forState:UIControlStateHighlighted];
    paginationButton.titleLabel.font = [UIFont primaryFont];
    [paginationButton addTarget:self action:@selector(loadMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    // flip horizontally for table view to be anchored to bottom
    [UIView transformViewFlipHorizontally:tableFooterView];
    
    [tableView.tableFooterView addSubview:paginationButton];
}

- (void)setPaginationFooterWithConversationCount:(NSInteger)count
{
    if (count < kSGNumberOfRecentlyReadMessages) {
        [self hidePaginationButton:NO];
    } else {
        [self showPaginationButton:NO];
    }
}

#pragma mark - Views

- (void)hidePaginationButton:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*) obj;
        if (view.tag == kSGPaginationButtonTag) {
            [UIView animateWithDuration:duration animations:^{
                view.alpha = 0.0;
            }];
        }
    }];
}

- (void)showPaginationButton:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*) obj;
        if (view.tag == kSGPaginationButtonTag) {
            [UIView animateWithDuration:duration animations:^{
                view.alpha = 1.0;
            }];
        }
    }];
}

- (void)hideLoadingTableFooterViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*) obj;
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [UIView animateWithDuration:duration animations:^{
                ((UIActivityIndicatorView*) view).alpha = 0.0;
            }];
        }
    }];
}

- (void)showLoadingTableFooterViewAnimated:(BOOL)animated
{
    __block UIActivityIndicatorView *spinnerView;
    CGFloat duration = animated ? 0.3 : 0.0;
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*) obj;
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            spinnerView = (UIActivityIndicatorView*) view;
            [UIView animateWithDuration:duration animations:^{
                spinnerView.alpha = 1.0;
            }];
        }
    }];
    if (!spinnerView) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinnerView.center = CGPointMake(CGRectGetMidX(self.tableView.tableFooterView.bounds), kSGThreadViewFooterOffset + kSGThreadViewPaginationViewHeight/2);
        [self.tableView.tableFooterView addSubview:spinnerView];
        [spinnerView startAnimating];
    }
}

- (void)showLastVideoLabelAnimated:(BOOL)animated
{
    JNLogRect(self.tableView.tableFooterView.frame);
    // hide pagination button
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*) obj;
        if (view.tag == kSGPaginationButtonTag) {
            [UIView animateWithDuration:kSGDefaultAnimationDuration animations:^{
                view.alpha = 0.0;
            }];
        }
    }];
    // show last video label
    UILabel *lastVideoLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake(0.0, 0.0,
                                          self.tableView.tableFooterView.bounds.size.width - 2 * kSGPaginationButtonHorizontalPadding,
                                          kSGThreadViewPaginationViewHeight)];
    lastVideoLabel.center = CGPointMake(CGRectGetMidX(self.tableView.tableFooterView.bounds), kSGThreadViewFooterOffset + kSGThreadViewPaginationViewHeight/2);
    lastVideoLabel.backgroundColor = [UIColor clearColor];
    lastVideoLabel.text = NSLocalizedString(@"last video text", nil);
    lastVideoLabel.textAlignment = NSTextAlignmentCenter;
    lastVideoLabel.textColor = JNWhiteColor;
    lastVideoLabel.font = [UIFont primaryFont];
    [self.tableView.tableFooterView addSubview:lastVideoLabel];
    lastVideoLabel.alpha = 0.0;
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        lastVideoLabel.alpha = 1.0;
    }];
}

#pragma mark - Actions

- (void)loadMoreAction:(id)sender
{
    JNLog();
    [self showLoadingTableFooterViewAnimated:YES];
    [self hidePaginationButton:YES];
    [self performSyncPagination];
}

#pragma mark -

- (void)performSyncPagination
{
    JNLog();
    if (!self.pageNumber) {
        self.pageNumber = @(2);
    } else {
        self.pageNumber = @(self.pageNumber.intValue + 1);
    }
    JNLogObject(self.pageNumber);
    // perform pagination fetch
    @weakify(self);
    // fetch recently read messages
    [SGMessage
     fetchRecentlyReadMessagesByConversationID:self.conversation.identifier
     pageNumber:self.pageNumber
     didFetchLocalReadMessages:^(NSArray *readMessages) {
         JNLogPrimitive(readMessages.count);
     } success:^(NSArray *recentlyReadMessages) {
         JNLog(@"completed: %@", @(recentlyReadMessages.count));
         @strongify(self);
         runOnAsyncDefaultQueue(^{
             // index set
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.messages.count, recentlyReadMessages.count)];
             NSArray *sortedMessages = [self sortMessages:recentlyReadMessages ascending:NO];
             // insert videos
             [self.messages
              insertObjects:sortedMessages
              atIndexes:indexSet];
             
             // update table
             NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:sortedMessages.count];
             [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                 [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
             }];

             
             
//             // group watched videos
//             [self groupSortedMessages:sortedMessages completed:^(NSArray *groupedMessages) {
//                 // index set
//                 NSIndexSet *groupedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.groupedMessages.count, groupedMessages.count)];
//                 // insert into data source
//                 [self.groupedMessages insertObjects:groupedMessages atIndexes:groupedIndexSet];
//                 // update table
//                 NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:groupedMessages.count];
//                 [groupedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//                     [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
//                 }];
             
             
                 runOnMainQueue(^{
                     [CATransaction begin];
                     [self.tableView beginUpdates];
                     [CATransaction setCompletionBlock: ^{
                         // update ui
                         if ([NSArray isNotEmptyArray:recentlyReadMessages]) {
                             [self hideLoadingTableFooterViewAnimated:YES];
                             [self showPaginationButton:YES];
                         } else {
                             [self hideLoadingTableFooterViewAnimated:YES];
                             [self showLastVideoLabelAnimated:YES];
                         }
                     }];
                     // insert rows
                     [self.tableView
                      insertRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationAutomatic];
                     
                     [self.tableView endUpdates];
                     [CATransaction commit];
                 });
             
//             }];
             
         });
         
     } fail:^(NSString *errorMessage) {
         
         JNLog(@"failed");
         runOnMainQueue(^{
             [self hideLoadingTableFooterViewAnimated:YES];
             [self showPaginationButton:YES];
             
             [self displayError:JNLocalizedString(@"single subject pagination error body")];
         });
     }];
}

@end
