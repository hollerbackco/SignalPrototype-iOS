//
//  SGVideo.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "MTLValueTransformer.h"

#import "SGVideo.h"
#import "JNFileUtils.h"

@implementation SGVideo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"identifier": @"id",
                                   @"guid": @"guid",
                                   @"conversationID": @"conversation_id",
                                   @"url": @"url",
                                   @"thumbURL": @"thumb_url",
                                   @"gifURL": @"gif_url",
                                   @"isRead": @"isRead",
                                   @"senderID": @"sender_id",
                                   @"senderName": @"sender_name",
                                   @"sentAt": @"sent_at",
                                   @"needsReply": @"needs_reply",
                                   @"subtitle": @"subtitle",
                                   @"thumbGravity": @"thumb_gravity",
                                   @"thumbStyle": @"thumb_style",
                                   @"fileDownloaded": @"file_downloaded",
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

+ (NSValueTransformer*)thumbGravityJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id obj) {
        return [self.class numberFromThumbGravityString:obj];
    } reverseBlock:^id(id obj) {
        return [self.class stringFromThumbGravityNumber:obj];
    }];
}

+ (NSNumber*)numberFromThumbGravityString:(NSString*)thumbGravity
{
    if ([NSString isNotEmptyString:thumbGravity]) {
        if ([thumbGravity isEqualToString:@"left"]) {
            return @(kSGVideoThumbGravityLeft);
        } else if ([thumbGravity isEqualToString:@"center"]) {
            return @(kSGVideoThumbGravityCenter);
        } else if ([thumbGravity isEqualToString:@"right"]) {
            return @(kSGVideoThumbGravityRight);
        }
    }
    return @(kSGVideoThumbGravityNone);
}

+ (NSString*)stringFromThumbGravityNumber:(NSNumber*)thumbGravity
{
    switch (thumbGravity.intValue) {
        case kSGVideoThumbGravityLeft:
            return @"left";
            break;
        case kSGVideoThumbGravityCenter:
            return @"center";
            break;
        case kSGVideoThumbGravityRight:
            return @"right";
            break;
        default:
            return @"none";
            break;
    }
}

+ (NSValueTransformer*)thumbStyleJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id obj) {
        return [self.class numberFromThumbStyleString:obj];
    } reverseBlock:^id(id obj) {
        return [self.class stringFromThumbStyleNumber:obj];
    }];
}

+ (NSNumber*)numberFromThumbStyleString:(NSString*)thumbStyle
{
    if ([NSString isNotEmptyString:thumbStyle]) {
        if ([thumbStyle isEqualToString:@"round"]) {
            return @(kSGVideoThumbStyleRound);
        } else if ([thumbStyle isEqualToString:@"square"]) {
            return @(kSGVideoThumbStyleSquare);
        }
    }
    return @(kSGVideoThumbStyleNone);
}

+ (NSString*)stringFromThumbStyleNumber:(NSNumber*)thumbStyle
{
    switch (thumbStyle.intValue) {
        case kSGVideoThumbStyleRound:
            return @"round";
            break;
        case kSGVideoThumbStyleSquare:
            return @"square";
            break;
        default:
            return @"none";
            break;
    }
}

- (NSString*)localFilePath
{
    return [NSString stringWithFormat:@"%@/%@.mp4", [JNFileUtils getTempVideosPath], self.guid];
}

- (NSURL*)videoURL
{
    NSString *videoFilePath = self.localFilePath;
    if ([JNFileUtils fileExists:videoFilePath]) {
        JNLog(@"local url: %@", videoFilePath);
        return [NSURL fileURLWithPath:videoFilePath isDirectory:NO];
    } else {
        JNLog(@"remote url: %@", self.url);
        return [NSURL URLWithString:self.url];
    }
}

@end
