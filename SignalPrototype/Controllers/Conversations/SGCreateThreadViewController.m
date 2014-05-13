//
//  SGCreateThreadViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <EXTScope.h>

#import "JNIcon.h"

#import "SGCreateThreadViewController.h"
#import "SGConversationsViewController.h"
#import "SGCreateConversationContext.h"
#import "SGSendToViewController.h"
#import "SGConversation+Service.h"

@interface SGCreateThreadViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) SGConversationsViewController *conversationsViewController;
@property (nonatomic, strong) SGSendToViewController *sendToViewController;

@property (nonatomic, strong) SGCreateConversationContext *createConversationContext;

@end

@implementation SGCreateThreadViewController

- (void)viewDidLoad
{
    JNLog();
    self.title = JNLocalizedString(@"Signal");
    
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    
    [self applyInboxNavigationButtonWithTarget:self action:@selector(listAction:)];
}

- (void)applyInboxNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon inboxImageIconWithSize:30.0 color:JNGrayColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = leftBarButtonItem;
}

- (void)setupViews
{
    self.messageTextField.backgroundColor = JNClearColor;
    self.messageTextField.placeholder = JNLocalizedString(@"Type something");
    self.messageTextField.font = [UIFont primaryFontWithSize:20.0];
    self.messageTextField.textColor = JNGrayColor;
    self.messageTextField.textAlignment = NSTextAlignmentCenter;
    self.messageTextField.returnKeyType = UIReturnKeyNext;
    self.messageTextField.delegate = self;
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.sendToViewController) {
        self.sendToViewController = nil;
    }
}

#pragma mark - Actions

- (void)listAction:(id)sender
{
    [self pushToConversationsViewController];
}

- (void)cameraAction:(id)sender
{
    
}

#pragma mark - Pushes

- (void)pushToConversationsViewController
{
    if (!self.conversationsViewController) {
        self.conversationsViewController = [[SGConversationsViewController alloc] initWithNib];
    }
    [self.navigationController pushViewController:self.conversationsViewController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    JNLog();
    
    NSString *messageText = textField.text;
    if ([NSString isNotEmptyString:messageText]) {
        [self setupSelectContactsViewControllerWithMessageText:messageText];
        [self pushToSelectContactsViewController];
    }
    
    return YES;
}

#pragma mark - Select Contacts

- (void)setupSelectContactsViewControllerWithMessageText:(NSString*)messageText
{
    if (!self.sendToViewController) {
        self.sendToViewController = [[SGSendToViewController alloc] initWithNib];
    }
    
    self.sendToViewController.createConversationContext = nil;
    
    SGCreateConversationContext *createConversationContext = [SGCreateConversationContext new];
    createConversationContext.messageText = messageText;
    self.sendToViewController.createConversationContext = createConversationContext;
    
    @weakify(self);
    self.sendToViewController.didSelectFriends = ^(SGSendToViewController *viewController, SGCreateConversationContext *createConversationContext) {
        
        
        JNLogObject(createConversationContext);
        [self_weak_ didSelectFriends:createConversationContext completed:^(SGConversation *conversation) {
            
            [self_weak_ didCreateConversation:conversation];
            
        } failed:^(NSString *errorMessage) {
            
            [self_weak_ failedToCreateConversation:errorMessage];
            
        }];
    };
}

- (void)pushToSelectContactsViewController
{
    [self.navigationController pushViewController:self.sendToViewController animated:YES];
}

#pragma mark - Did Select Contacts

- (void)didSelectFriends:(SGCreateConversationContext*)createConversationContext
               completed:(void(^)(SGConversation *conversation))completed
                  failed:(void(^)(NSString *errorMessage))failed
{
    // perform create
    [self performCreateConversation:createConversationContext completed:^(SGConversation *conversation) {
        
        if (completed) {
            completed(conversation);
        }
        
    } failed:^(NSString *errorMessage) {
        
        if (failed) {
            failed(errorMessage);
        }
        
    }];
}

- (void)performCreateConversation:(SGCreateConversationContext*)createConversationContext
                        completed:(void(^)(SGConversation *conversation))completed
                           failed:(void(^)(NSString *errorMessage))failed
{
    JNLog();
    
    // usernames list
    NSArray *usernames = [SGContact buildUsernamesFromFriends:createConversationContext.selectedContacts];
    JNLogPrimitive(usernames.count);
    
//    // phone number list
//    NSArray *invitePhoneNumbers = [SGContact buildInvitePhoneNumbersFromFriends:selectedFriends];
//    NSArray *inviteContacts = [SGContact buildInviteContactsFromFriends:selectedFriends];
//    self.selectedAddressBookContacts = inviteContacts;
//    JNLogPrimitive(inviteContacts.count);
    
    NSString *groupName = createConversationContext.messageText;
    
    // create conversation
    [SGConversation
     createConversationWithParts:nil
     usernames:usernames
     invites:nil
     name:groupName
     completed:^(SGConversation *conversation) {
//         // create invitee list
//         if ([NSArray isNotEmptyArray:inviteContacts]) {
//             [inviteContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                 [SGInvitee saveInviteeFromObject:obj withConversationID:conversation.identifier];
//             }];
//         }
        
         if (completed) {
             completed(conversation);
         }
     }
     failed:^(NSString *errorMessage) {
         JNLogObject(errorMessage);
         if (failed) {
             failed(errorMessage);
         }
         
//         // stop loading spinner in send to view
//         [self.sendToViewController hideLoadingSpinnerInNextButton];
     }];
}

- (void)didCreateConversation:(SGConversation*)conversation
{
    JNLogObject(conversation);
    
    [self pushToConversationsViewController];
}

- (void)failedToCreateConversation:(NSString*)errorMessage
{
    JNLogObject(errorMessage);
    [JNAlertView showWithTitle:@"Oops" body:errorMessage];
}

@end
