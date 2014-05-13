//
//  SGThreadViewController+Pagination.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 25/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGThreadViewController.h"

@interface SGThreadViewController ()

@property (nonatomic, strong) NSNumber *pageNumber;

@end

@interface SGThreadViewController (Pagination)

#pragma mark - Public methods

- (void)setupPaginationInTableView:(UITableView*)tableView;

- (void)setPaginationFooterWithConversationCount:(NSInteger)count;

#pragma mark - Views

- (void)hidePaginationButton:(BOOL)animated;

- (void)showPaginationButton:(BOOL)animated;

@end
