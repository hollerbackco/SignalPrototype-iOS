//
//  SGCreateThreadViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "SGCreateThreadViewController.h"
#import "SGConversationsViewController.h"

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
}

- (void)setupNavigationBar
{
    [self applyGearNavigationButtonWithTarget:self action:@selector(listAction:)];
}

#pragma mark - Actions

- (void)listAction:(id)sender
{
    if (!self.conversationsViewController) {
        self.conversationsViewController = [[SGConversationsViewController alloc] initWithNib];
    }
    [self.navigationController pushViewController:self.conversationsViewController animated:YES];
}

@end
