//
//  JNViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 5/12/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "JNViewController.h"

@interface JNViewController ()

@end

@implementation JNViewController

#pragma mark - Inits

- (void)initialize
{
    // subclass should override this
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (id)initWithNib
{
    if (self == [super initWithNibName:NSStringFromClass(self.class) bundle:nil]) {
        [self initialize];
    }
    return self;
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.hideNavigationBar) {
        [self setupNavigationBar];
    }
    
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

// Hack to remove shadow from translucent nav bar
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)setupNavigationBar
{
}

#pragma mark - Actions

- (void)goBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Active/Inactive application observer methods

- (void)observeApplicationNotifications
{
    JNLog();
    if (self.didBecomeActiveObserver) {
        [self.didBecomeActiveObserver dispose];
    }
    self.didBecomeActiveObserver =
    [self observeNotification:UIApplicationDidBecomeActiveNotification
                     notified:^(NSNotification *note) {
                         JNLog(@"%@: %@", self.class, note.name);
                         if (self.applicationDidBecomeActiveBlock) {
                             self.applicationDidBecomeActiveBlock(note);
                         }
                     }];
}

- (void)disposeApplicationObservers
{
    JNLog();
    if (self.didBecomeActiveObserver) {
        [self.didBecomeActiveObserver dispose];
    }
}

#pragma mark - Display Error

- (void)displayError:(NSString*)errorMessage
{
    if ([NSString isNullOrEmptyString:errorMessage]) {
        errorMessage = JNLocalizedString(@"failed.request.alert.body");
    }
    [JNAlertView showWithTitle:JNLocalizedString(@"failed.request.alert.title") body:errorMessage];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    JNLog(@"***********");
    JNLog(@"*********** %@", self.class);
    JNLog(@"***********");
    JNLog();
    [super didReceiveMemoryWarning];
}

@end
