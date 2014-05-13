//
//  SGConversationsTableViewCell.h
//  SignalPrototype
//
//  Created by Joe Nguyen on 12/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSGConversationsTableViewCellHeight 68.0

@interface SGConversationsTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, copy) NSString *sentAt;
@property (nonatomic, copy) NSString *messageText;

@end
