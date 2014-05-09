//
//  HBBaseWelcomeViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNViewController.h"

@interface HBBaseWelcomeViewController : JNViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentBodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIImageView *phoneOutlineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneInnerImageView0;
@property (weak, nonatomic) IBOutlet UIImageView *phoneInnerImageView1;

#pragma mark - Blocks

@property (nonatomic, copy) void(^finishedViewController)();

#pragma mark - Views

- (void)setupViews;

#pragma mark - Actions

- (IBAction)firstAction:(id)sender;
- (IBAction)secondAction:(id)sender;

@end
