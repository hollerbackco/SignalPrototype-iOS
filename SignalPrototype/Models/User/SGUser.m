//
//  SGUser.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGUser.h"

@implementation SGUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"identifier": @"id",
                                   @"name": @"name",
                                   @"username": @"username",
                                   @"phone": @"phone",
                                   @"phoneNormalized": @"phone_normalized",
                                   @"phoneHashed": @"phone_hashed",
                                   @"accessToken": @"access_token",
                                   @"isBlocked": @"is_blocked"};
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;    
}

@end
