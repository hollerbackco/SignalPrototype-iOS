//
//  SGSchemaAppVersion.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 6/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGSchemaAppVersion.h"

@implementation SGSchemaAppVersion

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"identifier": @"id",
                                   @"appVersion": @"app_version"
                                   };
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

@end
