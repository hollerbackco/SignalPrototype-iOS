//
//  SGMessage.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"
#import "SGVideo.h"
#import "SGMessageText.h"

#define kSGMessageTypeVideo @"video"
#define kSGMessageTypeText @"text"

@interface SGMessage : SGBaseModel

@property (nonatomic, strong) NSNumber *conversationID;
@property (nonatomic, copy) NSString *messageType;
@property (nonatomic, strong) NSDate *sentAt;
@property (nonatomic, strong) NSNumber *senderID;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, copy) NSString *contentGUID;
@property (nonatomic, strong) NSNumber *isRead;
@property (nonatomic, strong) SGVideo *video;
@property (nonatomic, strong) SGMessageText *messageText;

@end
