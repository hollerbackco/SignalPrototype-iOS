//
//  SGInvitee.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"

@interface SGInvitee : SGBaseModel

@property (nonatomic, strong) NSNumber *conversationID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phoneNumber;

@end
