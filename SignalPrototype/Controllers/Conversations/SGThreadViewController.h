//
//  SGThreadViewController.h
//  SignalPrototype
//
//  Created by Joe Nguyen on 12/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "JNViewController.h"

#import "SGConversation+Service.h"

@interface SGThreadViewController : JNViewController

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *subheaderView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
// Overlay view
@property (weak, nonatomic) IBOutlet UIView *infoOverlayView;
@property (weak, nonatomic) IBOutlet UIView *infoContentView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *infoMembersView;
@property (weak, nonatomic) IBOutlet UILabel *followersTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *followersTextView;
@property (weak, nonatomic) IBOutlet UILabel *recipientsTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *recipientsTextView;

@property (nonatomic, strong) SGConversation *conversation;
@property (nonatomic, strong) NSMutableArray *messages;

- (IBAction)infoAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
- (IBAction)sendAction:(id)sender;
- (IBAction)followAction:(id)sender;

- (NSArray*)sortMessages:(NSArray*)messages ascending:(BOOL)ascending;

@end

#import "SGThreadViewController+Info.h"

#import "SGThreadViewController+Pagination.h"

