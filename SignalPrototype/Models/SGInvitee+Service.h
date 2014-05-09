//
//  SGInvitee+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGInvitee.h"

@interface SGInvitee (Service)

+ (void)fetchInviteesForConversationID:(NSNumber*)conversationID
                             completed:(void(^)(NSArray *invitees))completed
                                failed:(void(^)())failed;

+ (void)saveInviteeFromObject:(id)obj withConversationID:(NSNumber*)conversationID;

- (NSArray*)phoneNumberToArray;

- (void)save;

@end
