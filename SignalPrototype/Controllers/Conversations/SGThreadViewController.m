//
//  SGThreadViewController.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 12/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <MHPrettyDate.h>

#import "JNIcon.h"

#import "SGThreadViewController.h"
#import "SGThreadTableViewCell.h"
#import "SGMessageText+Service.h"
#import "SGMessage+Service.h"
#import "SGUser+Service.h"

dispatch_queue_t threadViewQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("threadViewQueue", 0);
    });
    return queue;
}

void runOnThreadViewQueue(void (^block)(void))
{
    dispatch_async(threadViewQueue(), block);
}

@interface SGThreadViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation SGThreadViewController

#pragma mark - Public methods

- (BOOL)isThreadEmpty
{
    return !self.messages || self.messages.count == 0;
}

- (NSArray*)sortMessages:(NSArray*)messages ascending:(BOOL)ascending
{
    return [messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentAt" ascending:ascending]]];
}

- (void)showFooterViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.footerView.alpha = 1.0;
    }];
}

- (void)hideFooterViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.footerView.alpha = 0.0;
    }];
}

#pragma mark - Views

- (void)viewDidLoad
{
    self.title = self.conversation.senderName;
    
    [super viewDidLoad];
    
    [self setupViews];
    
    [self setupTableView];
    
    self.messages = [@[] mutableCopy];
    
    [self hidePaginationButton:NO];
    
    [self performFetchWithIncrementalUpdates:NO animatedScroll:NO];
    
    // mark all text as read in convo
//    [self  markAllMessageTextAsRead];
}

- (void)setupViews
{
    self.messageTextView.text = self.conversation.name;
    
    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    
    [self.cameraButton setTitle:nil forState:UIControlStateNormal];
    [self.cameraButton setImage:[JNIcon cameraImageIconWithSize:30.0 color:JNGrayColor] forState:UIControlStateNormal];
    
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    
    self.messageTextField.placeholder = @"Message";
    self.messageTextField.delegate = self;
}

static NSString *CellIdentifier = @"SGThreadTableViewCell";

- (void)setupTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView scrollsToTop];
    [self.tableView registerNib:[UINib nibWithNibName:@"SGThreadTableViewCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CellIdentifier];
}

#pragma mark Empty Thread

- (void)showEmptyThreadViewAnimated:(BOOL)animated
{
//    CGFloat duration = animated ? 0.3 : 0.0;
//    [UIView animateWithDuration:duration animations:^{
//        self.emptyThreadView.alpha = 1.0;
//    }];
}

- (void)hideEmptyThreadViewAnimated:(BOOL)animated
{
//    CGFloat duration = animated ? 0.3 : 0.0;
//    [UIView animateWithDuration:duration animations:^{
//        self.emptyThreadView.alpha = 0.0;
//    }];
}

#pragma mark - Actions

- (IBAction)followAction:(id)sender
{
}

- (IBAction)cameraAction:(id)sender
{
}

- (IBAction)sendAction:(id)sender
{
    NSString *messageText = self.messageTextField.text;
    
    if ([NSString isNotEmptyString:messageText]) {
        [self performMessageTextSend:messageText completed:^{
            ;
        }];
    }
    
    self.messageTextField.text = nil;
    [self.messageTextField resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get group
    SGMessage *message = self.messages[indexPath.row];
    
    // load cell, can be left or right display
    SGThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self tableView:tableView
      configureCell:cell
        atIndexPath:indexPath
            message:message];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView configureCell:(SGThreadTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    SGMessage *message = self.messages[indexPath.row];
    
    [self tableView:tableView
      configureCell:cell
        atIndexPath:indexPath
            message:message];
}

- (void)tableView:(UITableView *)tableView
    configureCell:(SGThreadTableViewCell*)cell
      atIndexPath:(NSIndexPath *)indexPath
          message:(SGMessage*)message
{
    cell.senderName = message.senderName;
    cell.sentAt = [MHPrettyDate prettyDateFromDate:message.sentAt withFormat:MHPrettyDateFormatTodayTimeOnly];
    
    SGMessageText *messageText = [message getMessageText];
    if (messageText) {
        cell.messageText = messageText.text;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *messageGroup = self.groupedMessages[indexPath.row];
//    // calculate cell height for text + video
//    CGFloat heightForRow = [SGThreadContentCell calculateCellHeightForMessageGroup:messageGroup];
//    return heightForRow;
    
    return kSGThreadTableViewCellMinHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Fetch

- (void)performFetchWithIncrementalUpdates:(BOOL)shouldUpdateIncrementally
                            animatedScroll:(BOOL)animatedScroll
{
    [self
     performFetchCompleted:^(NSArray *messages) {
         runOnThreadViewQueue(^{
             if ([NSArray isNotEmptyArray:messages]) {

                 // hide empty thread view
//                 runOnMainQueue(^{
//                     [self hideEmptyThreadViewAnimated:YES];
//                 });
                 
                 // sort messages by date
//                 self.messages = [[self sortMessages:messages ascending:NO] mutableCopy];
//                 // group messages by sender name
//                 [self groupSortedMessages:self.messages completed:^(NSArray *groupedMessages) {
//                     self.groupedMessages = [groupedMessages mutableCopy];
//                     runOnMainQueue(^{
//                         // reload table view
//                         [self reloadTableViewAndScrollToBottomAnimated:animatedScroll];
//                         // show/hide pagination footer
//                         [self setPaginationFooterWithConversationCount:messages.count];
//                     });
//                 }];
//                 
//                 if (!self.threadCameraViewController.isFakeThread) {
//                     // log metric
//                     [SGSession didOnboardingActivity:kSGOnboardingPreRecord
//                                           parameters:@{kSGOnboardingSourceParamKey:kSGOnboardingSourceParamExistingConvoKey}];
//                 }
                 
                 
                 self.messages = [[self sortMessages:messages ascending:YES] mutableCopy];
                 
                 runOnMainQueue(^{
                     // reload table view
                     [self reloadTableViewAndScrollToBottomAnimated:animatedScroll];
                     // show/hide pagination footer
                     [self setPaginationFooterWithConversationCount:messages.count];
                 });

             } else {
                 // show empty thread view
                 runOnMainQueue(^{
                     [self showEmptyThreadViewAnimated:NO];
                 });
             }
         });
     }
     failed:^(NSString *errorMessage) {
         runOnMainQueue(^{
             [self displayError:errorMessage];
         });
     }
     shouldUpdateIncrementally:shouldUpdateIncrementally
     animatedScroll:animatedScroll];
}

- (void)performFetchCompleted:(void(^)(NSArray *messages))completed
                       failed:(void(^)(NSString *errorMessage))failed
    shouldUpdateIncrementally:(BOOL)shouldUpdateIncrementally
               animatedScroll:(BOOL)animated
{
    JNLog();
    NSNumber *conversationID = self.conversation.identifier;
    [SGMessage
     fetchInitialMessagesWithConversationID:conversationID
     didFetchUnreadMessages:^(NSArray *unreadMessages) {
         
//         if (shouldUpdateIncrementally && [NSArray isNotEmptyArray:unreadMessages]) {
//             // Note: untested code below
//             JNLogPrimitive(unreadMessages.count);
//             runOnThreadViewQueue(^{
//                 [self sortAndGroupMessages:unreadMessages reloadAnimated:animated];
//                 [self.messages addObjectsFromArray:unreadMessages];
//                 // sort videos by date
//                 [self sortMessages:self.messages ascending:NO];
//                 // group videos by sender name
//                 [self groupSortedMessages:self.messages completed:^(NSArray *groupedMessages) {
//                     self.groupedMessages = [groupedMessages mutableCopy];
//                     runOnMainQueue(^{
//                         [self reloadTableViewAndScrollToBottomAnimated:animated];
//                     });
//                 }];
//             });
//         }
         
     } didFetchRecentlyReadMessages:^(NSArray *recentlyReadMessages) {
         
//         if (shouldUpdateIncrementally && [NSArray isNotEmptyArray:recentlyReadMessages]) {
//             // Note: untested code below
//             JNLogPrimitive(recentlyReadMessages.count);
//             runOnThreadViewQueue(^{
//                 [self sortAndGroupMessages:recentlyReadMessages reloadAnimated:animated];
//                 [self.messages addObjectsFromArray:recentlyReadMessages];
//                 // sort videos by date
//                 [self sortMessages:self.messages ascending:NO];
//                 // group videos by sender name
//                 [self groupSortedMessages:self.messages completed:^(NSArray *groupedMessages) {
//                     self.groupedMessages = [groupedMessages mutableCopy];
//                     runOnMainQueue(^{
//                         [self reloadTableViewAndScrollToBottomAnimated:animated];
//                     });
//                 }];
//             });
//         }
         
     } success:^(NSArray *initialMessages) {
         JNLogPrimitive(initialMessages.count);
         if (completed) {
             completed(initialMessages);
         }
     } fail:^(NSString *errorMessage) {
         [JNLogger logExceptionWithName:THIS_METHOD reason:@"could not fetch messages" error:nil];
         if (failed) {
             failed(errorMessage);
         }
     }];
}

//- (void)sortAndGroupMessages:(NSArray*)messages reloadAnimated:(BOOL)reloadAnimated
//{
//    [self.messages addObjectsFromArray:messages];
//    // sort messages by date
//    [self sortMessages:self.messages ascending:NO];
//    // group messages by sender name
//    [self groupSortedMessages:self.messages completed:^(NSArray *groupedMessages) {
//        self.groupedMessages = [groupedMessages mutableCopy];
//        runOnMainQueue(^{
//            [self reloadTableViewAndScrollToBottomAnimated:reloadAnimated];
//        });
//    }];
//}

- (void)reloadTableViewAndScrollToBottomAnimated:(BOOL)animated
{
    self.tableView.delegate = self;
    [self.tableView reloadData];
    
    [self.tableView scrollRectToVisible:CGRectMake(0.0, self.tableView.contentSize.height - 1.0, 1.0, 1.0) animated:animated];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithBlock:^{
        self.view.frame = CGRectSetY(self.view.frame, -kSGKeyboardHeight + kSGDefaultNavigationAndStatusBarHeight);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithBlock:^{
        self.view.frame = CGRectSetY(self.view.frame, kSGDefaultNavigationAndStatusBarHeight);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - Message Text Send

- (void)performMessageTextSend:(NSString*)text completed:(void(^)())completed
{
    // create SGMessage
    NSNumber *conversationID = self.conversation.identifier;
    NSDate *sentAt = [NSDate date];
    NSNumber *senderID = [SGUser getCurrentUserId];
    NSString *senderName = [SGUser getCurrentUsername];
    NSString *messageTextGUID = [SGBaseModel generateGUID];
    NSNumber *isRead = @(YES);
    
    // create message and save locally
    SGMessage *message = [SGMessage new];
    message.contentGUID = messageTextGUID;
    message.messageType = kSGMessageTypeText;
    message.conversationID = conversationID;
    message.sentAt = sentAt;
    message.senderID = senderID;
    message.senderName = senderName;
    message.isRead = isRead;
    [message save];
    
    // create SGMessageText
    SGMessageText *messageText = [SGMessageText new];
    messageText.guid = messageTextGUID;
    messageText.text = text;
    [messageText save];
    
    [self didFinishMessageTextSave:message];
    
    // perform remote save in background
    runOnAsyncDefaultQueue(^{
        [SGMessageText
         createWithText:text
         guid:messageTextGUID
         conversationID:conversationID
         completed:^(SGMessageText *messageText) {
             JNLogObject(messageText);
         }
         failed:^(NSString *errorMessage) {
             JNLogObject(errorMessage);
             runOnMainQueue(^{
                 [self displayError:errorMessage];
             });
         }];
    });
}

- (void)didFinishMessageTextSave:(SGMessage*)message
{
    JNLog();
    runOnThreadViewQueue(^{
        
        [self.messages addObject:message];
        
        runOnMainQueue(^{
            [self reloadTableViewAndScrollToBottomAnimated:YES];
        });
    });
}

@end
