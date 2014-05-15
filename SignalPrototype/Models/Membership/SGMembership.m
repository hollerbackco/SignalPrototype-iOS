//
//  SGMembership.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMembership.h"

@implementation SGMembership

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"following": @"following"
                                   };
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

@end
