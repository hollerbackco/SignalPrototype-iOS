//
//  SGCreateThreadViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "SGCreateThreadViewController.h"
#import "SGConversationsViewController.h"
#import "JNIcon.h"

@interface SGCreateThreadViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) SGConversationsViewController *conversationsViewController;

@end

@implementation SGCreateThreadViewController

- (void)viewDidLoad
{
    self.title = JNLocalizedString(@"Signal");
    
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    
    [self applyInboxNavigationButtonWithTarget:self action:@selector(listAction:)];
}

- (void)setupViews
{
    self.messageTextField.backgroundColor = JNClearColor;
    self.messageTextField.placeholder = JNLocalizedString(@"Type something");
    self.messageTextField.font = [UIFont primaryFontWithSize:20.0];
    self.messageTextField.textColor = JNGrayColor;
    self.messageTextField.textAlignment = NSTextAlignmentCenter;
    
    self.cameraButton.backgroundColor = JNClearColor;
    [self.cameraButton setImage:[JNIcon cameraImageIconWithSize:30.0 color:JNGrayColor] forState:UIControlStateNormal];
    self.cameraButton.tintColor = JNGrayColor;
    self.cameraButton.imageView.contentMode = UIViewContentModeCenter;
    [self.cameraButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.messageTextField becomeFirstResponder];
}

#pragma mark - Actions

- (void)listAction:(id)sender
{
    if (!self.conversationsViewController) {
        self.conversationsViewController = [[SGConversationsViewController alloc] initWithNib];
    }
    [self.navigationController pushViewController:self.conversationsViewController animated:YES];
}

- (void)cameraAction:(id)sender
{
    
}

@end
