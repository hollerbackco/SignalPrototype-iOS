//
//  JNViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 5/12/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

#import "UIView+JNHelper.h"
#import "UIViewController+JNHelper.h"
#import "UIFont+JNHelper.h"
#import "UIColor+JNHelper.h"

#import "JNAlertView.h"

@interface JNViewController : UIViewController

@property (nonatomic) BOOL hideNavigationBar;

#pragma mark - Active/Inactive application observer properties

@property (nonatomic, strong) RACDisposable *didBecomeActiveObserver;
@property (nonatomic, copy) void(^applicationDidBecomeActiveBlock)(NSNotification *note);

#pragma mark - Properties

@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

#pragma mark -

// subclass should override this
- (void)initialize;

- (id)initWithNib;

- (void)setupNavigationBar;

#pragma mark - Actions

- (void)goBackAction:(id)sender;

#pragma mark - Active/Inactive application observer methods

- (void)observeApplicationNotifications;
- (void)disposeApplicationObservers;

#pragma mark - Display Error

- (void)displayError:(NSString*)errorMessage;

@end
