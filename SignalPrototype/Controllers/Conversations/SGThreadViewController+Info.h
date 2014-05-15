//
//  SGThreadViewController+Info.h
//  SignalPrototype
//
//  Created by Joe Nguyen on 15/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "SGThreadViewController.h"

@interface SGThreadViewController ()

@property (nonatomic, strong) NSArray *followers;
@property (nonatomic, strong) NSArray *recipients;

@end

@interface SGThreadViewController (Info)

#pragma mark - Views

- (void)setupInfoView;

- (void)toggleInfoView;

- (void)showInfoView;

- (void)hideInfoView;

@end
