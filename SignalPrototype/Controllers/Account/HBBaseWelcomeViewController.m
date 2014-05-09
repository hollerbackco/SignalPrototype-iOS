//
//  HBBaseWelcomeViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "HBBaseWelcomeViewController.h"

@interface HBBaseWelcomeViewController ()

@end

@implementation HBBaseWelcomeViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews
{
    self.view.backgroundColor = JNWhiteColor;
    
    self.contentView.backgroundColor = JNClearColor;
    
    self.contentTitleLabel.font = [UIFont primaryFontWithSize:24.0];
    self.contentTitleLabel.textColor = JNBlackTextColor;
    self.contentTitleLabel.numberOfLines = 0;
    
    self.contentBodyLabel.font = [UIFont primaryFontWithSize:17.5];
    self.contentBodyLabel.textColor = JNBlackTextColor;
    self.contentBodyLabel.numberOfLines = 0;
    
    [self applyButtonStyle:self.firstButton];
    
    [self applyButtonStyle:self.secondButton];
}

- (void)applyButtonStyle:(UIButton*)button
{
    button.backgroundColor = JNLightGrayColor;
    button.titleLabel.font = [UIFont primaryFontWithSize:20.0];
    [button setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.layer.cornerRadius = 5.0;
    button.layer.shadowColor = JNBlackColor.CGColor;
    button.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowRadius = 1.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // white status bar text
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // dark status bar text
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - Actions

- (IBAction)firstAction:(id)sender
{
    // subclass must override
}

- (IBAction)secondAction:(id)sender;
{
    // subclass must override
}

@end
