//
//  SGSendToViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNViewController.h"
#import "SGCreateConversationContext.h"

@interface SGSendToViewController : JNViewController <UITextFieldDelegate>

@property (nonatomic) BOOL canCancel;

// group name
@property (weak, nonatomic) IBOutlet UIView *groupNameView;

@property (nonatomic, copy) void(^didCancel)(SGSendToViewController *viewController);
@property (nonatomic, copy) void(^didSelectFriends)(SGSendToViewController *viewController, SGCreateConversationContext *createConversationContext);

#pragma mark - Views

- (void)showLoadingSpinnerInNextButton;
- (void)hideLoadingSpinnerInNextButton;

#pragma mark - Actions

- (IBAction)headerSegmentedControlAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (void)goBackAction:(id)sender;

#pragma mark - Build Contacts

-(void)buildSplitContacts;

#pragma mark - Footer and group name views

- (void)showFooterViewAnimated:(BOOL)animated;
- (void)showGroupNameViewAnimated:(BOOL)animated;

#pragma mark - Create Conversation Context

@property (nonatomic, strong) SGCreateConversationContext *createConversationContext;

@end

#import "JNViewController+MultiValueSelector.h"
