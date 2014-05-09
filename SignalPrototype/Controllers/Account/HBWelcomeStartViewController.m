//
//  HBWelcomeStartViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "HBWelcomeStartViewController.h"

@interface HBWelcomeStartViewController ()

@end

@implementation HBWelcomeStartViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setupViews
{
    [super setupViews];
    
    self.logoImageView.image = [UIImage imageNamed:@"big-banana.png"];
    
    self.contentTitleLabel.font = [UIFont primaryFontWithSize:50.0];
    self.contentTitleLabel.text = JNLocalizedString(@"welcome.start.title");
    self.contentTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentBodyLabel.font = [UIFont primaryFontWithTitleSize];
    self.contentBodyLabel.text = JNLocalizedString(@"welcome.start.body");
    self.contentBodyLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.firstButton setTitle:JNLocalizedString(@"welcome.start.first.button.text") forState:UIControlStateNormal];
    self.firstButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.firstButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.firstButton.titleEdgeInsets = UIEdgeInsetsZero;
    [self.secondButton setTitle:JNLocalizedString(@"welcome.start.second.button.text") forState:UIControlStateNormal];
    self.secondButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.secondButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.secondButton.titleEdgeInsets = UIEdgeInsetsZero;
}

#pragma mark - Actions

- (void)firstAction:(id)sender
{
    if (self.finishedViewController) {
        self.finishedViewController();
    }
}

- (void)secondAction:(id)sender
{
    if (self.loginBlock) {
        self.loginBlock();
    }
}

@end
