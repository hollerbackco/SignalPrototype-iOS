//
//  SGMessage.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMessage.h"

@implementation SGMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"conversationID": @"conversation_id",
                                   @"messageType": @"type",
                                   @"sentAt": @"sent_at",
                                   @"senderID": @"sender_id",
                                   @"senderName": @"sender_name",
                                   @"contentGUID": @"content_guid",
                                   @"isRead": @"is_read",
                                   };
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

+ (NSValueTransformer *)sentAtJSONTransformer
{
    return [SGBaseModel JSONDateTransformer];
}

@end
