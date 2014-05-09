//
//  SGInvitee.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGInvitee.h"

@implementation SGInvitee

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"identifier": @"id",
                                   @"conversationID": @"conversation_id",
                                   @"name": @"name",
                                   @"phoneNumber": @"phone_number"
                                   };
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

@end
