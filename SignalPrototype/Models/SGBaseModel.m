//
//  SGBaseModel.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"

@implementation SGBaseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"createdAt": @"created_at",
             @"updatedAt": @"updated_at",
             @"deletedAt": @"deleted_at"};
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [SGBaseModel JSONDateTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [SGBaseModel JSONDateTransformer];
}

+ (NSValueTransformer *)deletedAtJSONTransformer
{
    return [SGBaseModel JSONDateTransformer];
}

+ (NSValueTransformer*)JSONDateTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *date) {
        if ([date isKindOfClass:[NSString class]]) {
            return [[NSDate dateFormatter] dateFromString:date];
        } else if ([date isKindOfClass:[NSNumber class]]) {
            return [NSDate dateWithTimeIntervalSince1970:((NSNumber*) date).doubleValue];
        } else {
            return [NSDate dateWithTimeIntervalSince1970:0];
        }
    } reverseBlock:^(NSDate *date) {
        return [[NSDate dateFormatter] stringFromDate:(NSDate*) date];
    }];
}

+ (SGBaseModel*)initFromJSONDictionary:(NSDictionary*)jsonDictionary
{
    NSError *error;
    SGBaseModel *baseModel = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:jsonDictionary error:&error];
    if (!baseModel) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"error processing model" error:error];
    }
    return baseModel;
}

+ (NSString *)generateGUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return [uuidString lowercaseString];
}

@end
