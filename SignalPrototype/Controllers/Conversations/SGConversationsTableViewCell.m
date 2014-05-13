//
//  SGConversationsTableViewCell.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 12/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "UIView+JNHelper.h"
#import "UIFont+JNHelper.h"
#import "UIColor+JNHelper.h"

#import "JNIcon.h"

#import "SGConversationsTableViewCell.h"

@interface SGConversationsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;

@end

@implementation SGConversationsTableViewCell

- (void)awakeFromNib
{
    self.senderNameLabel.font = [UIFont primaryFont];
    self.sentAtLabel.font = [UIFont primaryFont];
    self.messageTextLabel.font = [UIFont primaryFont];
    
    [self resetCellValues];
}

- (void)resetCellValues
{
    [self.followButton setTitle:nil forState:UIControlStateNormal];
    [self.followButton setAttributedTitle:[JNIcon plusOutlineIconWithSize:30.0 color:JNBlackTextColor] forState:UIControlStateNormal];
    self.senderNameLabel.text = nil;
    self.sentAtLabel.text = nil;
    self.messageTextLabel.text = nil;
}

#pragma mark - Properties

- (void)setSenderName:(NSString *)senderName
{
    self.senderNameLabel.text = senderName;
}

- (void)setSentAt:(NSString *)sentAt
{
    self.sentAtLabel.text = sentAt;
}

- (void)setMessageText:(NSString *)messageText
{
    self.messageTextLabel.text = messageText;
}

#pragma mark - 


@end
