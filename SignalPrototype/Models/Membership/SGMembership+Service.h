//
//  SGMembership+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMembership.h"

@interface SGMembership (Service)

+ (void)getMembersWithConversationID:(NSNumber*)conversationID
                           completed:(void(^)(NSArray *members))completed
                              failed:(void(^)(NSString *errorMessage))failed;

@end
