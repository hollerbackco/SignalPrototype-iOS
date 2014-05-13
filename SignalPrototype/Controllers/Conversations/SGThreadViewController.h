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
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) SGConversation *conversation;
@property (nonatomic, strong) NSMutableArray *messages;

- (IBAction)followAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
- (IBAction)sendAction:(id)sender;

- (NSArray*)sortMessages:(NSArray*)messages ascending:(BOOL)ascending;

@end

#import "SGThreadViewController+Pagination.h"
