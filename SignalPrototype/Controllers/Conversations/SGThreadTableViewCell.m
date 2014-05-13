//
//  SGThreadTableViewCell.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 12/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "UIFont+JNHelper.h"

#import "SGThreadTableViewCell.h"

@interface SGThreadTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;

@end

@implementation SGThreadTableViewCell

- (void)awakeFromNib
{
    self.senderNameLabel.font = [UIFont primaryFont];
    self.sentAtLabel.font = [UIFont primaryFont];
    self.sentAtLabel.textAlignment = NSTextAlignmentRight;
    self.messageTextLabel.font = [UIFont primaryFont];
    
    [self resetCellValues];
}

- (void)resetCellValues
{
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

@end
