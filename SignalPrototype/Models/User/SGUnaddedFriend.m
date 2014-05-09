//
//  SGUnaddedFriend.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGUnaddedFriend.h"

@implementation SGUnaddedFriend

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{@"isNew": @"is_new"};
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

@end
