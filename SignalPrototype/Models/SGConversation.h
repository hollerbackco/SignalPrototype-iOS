//
//  SGConversation.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

#import "SGBaseModel.h"

@interface SGConversation : SGBaseModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *lastMessageAt;
@property (nonatomic, copy) NSString *mostRecentThumbURL;
@property (nonatomic, copy) NSString *mostRecentSubtitle;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) NSNumber *colorCode;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSNumber *isDeleted;
@property (nonatomic, strong) NSNumber *backgroundImageNumber;

+ (int)colorKey;

@end
