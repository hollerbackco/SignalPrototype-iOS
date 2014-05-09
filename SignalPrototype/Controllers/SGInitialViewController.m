//
//  SGInitialViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 9/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "SGInitialViewController.h"
#import "HBLoginViewController.h"

@interface SGInitialViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)signUpAction:(id)sender;
- (IBAction)loginAction:(id)sender;

@end

@implementation SGInitialViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews
{
    self.signUpButton.backgroundColor = JNClearColor;
    self.loginButton.backgroundColor = JNClearColor;
    
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)signUpAction:(id)sender
{
    HBLoginViewController *loginViewController = [[HBLoginViewController alloc] initWithNib];
    loginViewController.mode = HBLoginViewControllerRegisterMode;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)loginAction:(id)sender
{
    HBLoginViewController *loginViewController = [[HBLoginViewController alloc] initWithNib];
    loginViewController.mode = HBLoginViewControllerLoginMode;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

@end
