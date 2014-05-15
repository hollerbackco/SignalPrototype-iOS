//
//  SGConversation.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGConversation.h"
#import "MTLValueTransformer.h"

static int color = 1;

@implementation SGConversation

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"identifier": @"conversation_id",
             @"name": @"name",
             @"lastMessageAt": @"last_message_at",
             @"mostRecentThumbURL": @"most_recent_thumb_url",
             @"mostRecentSubtitle": @"most_recent_subtitle",
             @"unreadCount": @"unread_count",
             @"isDeleted": @"is_deleted",
             @"colorCode": @"color_code",
             @"backgroundImageNumber": @"background_image_number",
             @"senderName": @"sender_name",
             @"following": @"following"};
}

+ (NSValueTransformer *)lastMessageAtJSONTransformer
{
    return [SGBaseModel JSONDateTransformer];
}

+ (NSValueTransformer *)colorCodeJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSNumber *code) {
        if(!code) {
            code = [NSNumber numberWithInt:[self colorKey]];
        }
        return code;
    }];
}

+ (int)colorKey
{
    color = (color + 1) % 6;
    return color;
}

@end
