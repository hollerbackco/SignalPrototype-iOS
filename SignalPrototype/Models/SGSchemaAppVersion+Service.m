//
//  SGSchemaAppVersion+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 6/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <SWFSemanticVersion.h>

#import "SGSchemaAppVersion+Service.h"

@implementation SGSchemaAppVersion (Service)

+ (NSString*)getLatestAppVersion
{
    NSString *latestAppVersion = nil;
    id result =
    [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchFirstResultWithStatement:
     @"SELECT * FROM schema_app_version "
     @"ORDER BY created_at DESC "
     @"LIMIT 1", nil];
    if (result && [result respondsToSelector:@selector(objectForKey:)]) {
        SGSchemaAppVersion *schemaAppVersion = (SGSchemaAppVersion*) [SGSchemaAppVersion initFromJSONDictionary:result];
        latestAppVersion = [self.class normalizeAppVersion:schemaAppVersion.appVersion];
    }
    return latestAppVersion;
}

+ (void)updateLatestAppVersion:(NSString*)appVersion
{
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"INSERT OR REPLACE INTO schema_app_version ("
     @"app_version,"
     @"created_at,"
     @"updated_at) "
     @"VALUES (?,?,?)"
     arguments:
     @[[self.class normalizeAppVersion:appVersion],
       @([NSDate date].timeIntervalSince1970),
       @([NSDate date].timeIntervalSince1970)]];
}

+ (BOOL)isSchemaAppVersionExpired
{
    NSString *appVersion1 = [self.class getLatestAppVersion];
    NSString *appVersion2 = [JNAppManager getAppVersion];
    JNLogObject(appVersion1);
    JNLogObject(appVersion2);
    if (appVersion1 && appVersion2) {
        return [self.class isAppVersion:appVersion1 earlierThanAppVersion:appVersion2];
    } else {
        return YES;
    }
}

+ (BOOL)isAppVersion:(NSString*)appVersion1 earlierThanAppVersion:(NSString*)appVersion2
{
    SWFSemanticVersion *semVer1 = [SWFSemanticVersion semanticVersionWithString:
                                   [self.class normalizeAppVersion:appVersion1]];
    SWFSemanticVersion *semVer2 = [SWFSemanticVersion semanticVersionWithString:
                                   [self.class normalizeAppVersion:appVersion2]];
    return [semVer1 compare:semVer2] == NSOrderedAscending;
}

+ (NSString*)normalizeAppVersion:(NSString*)appVersion
{
    // strip any tailing full stops
    if ([[appVersion substringFromIndex:appVersion.length - 1] isEqualToString:@"."]) {
        appVersion = [appVersion stringByReplacingCharactersInRange:NSMakeRange(appVersion.length - 1, 1) withString:@""];
    }
    // suffix invalid schema versions with 0s
    NSArray *values = [appVersion componentsSeparatedByString:@"."];
    if ([NSArray isNotEmptyArray:values]) {
        if (values.count == 3) {
            return appVersion;
        } if (values.count == 2) {
            return [NSString stringWithFormat:@"%@.0", appVersion];
        } else if (values.count == 1) {
            return [NSString stringWithFormat:@"%@.0.0", appVersion];
        } else {
            return appVersion;
        }
    } else {
        return appVersion;
    }
}

@end
