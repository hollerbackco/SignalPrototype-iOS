//
//  SGMetrics.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Flurry.h>

#import "KeenClient.h"
#import "JNAppManager.h"

#import "SGMetrics.h"
#import "SGUser+Service.h"

@implementation SGMetrics

+ (void)addMetric:(NSString*)name
{
    [self.class addMetric:name withParameters:nil];
}

+ (NSDictionary*)addDefaultParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary *parameters = dictionary;
    if (![parameters objectForKey:SGKeenDefaultPropertyUserID]) {
        // set user id
        NSNumber *userId = [SGUser getCurrentUserId];
        if ([NSNumber isNotANumber:userId]) {
            userId = @(NSNotFound);
        }
        [parameters setValue:userId forKey:SGKeenDefaultPropertyUserID];
    }
    if (![parameters objectForKey:SGKeenDefaultPropertyAppVersion]) {
        // set app version
        [parameters setObject:[JNAppManager getAppVersion] forKey:SGKeenDefaultPropertyAppVersion];
    }
    return parameters;
}

+ (void)addMetric:(NSString*)name withObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstObject);
    NSMutableDictionary *parameters = [@{} mutableCopy];
    for (id valueArg = firstObject; valueArg != nil; valueArg = va_arg(args, id))
    {
        id keyArg = va_arg(args, id);
        [parameters setValue:(NSString*)valueArg forKey:(NSString*)keyArg];
    }
    va_end(args);
    
    [self.class addMetric:name withParameters:parameters];
}

+ (void)addMetric:(NSString *)name withParameters:(NSDictionary*)parameters
{
    [self addEvent:[self.class addDefaultParametersToDictionary:[parameters mutableCopy]] toEventCollection:name];
}

+ (void)uploadMetrics
{
    [[KeenClient sharedClient] uploadWithFinishedBlock:^{
        JNLog(@"uploadWithFinishedBlock");
    }];
}

+ (void)logFlurryEvent:(NSString*)eventName
{
    [Flurry logEvent:eventName];
}

@end


@implementation SGMetrics (Keen)

+ (void)setupMetrics
{
    return;
    
    // Keen IO
    [KeenClient disableGeoLocation];
    [KeenClient sharedClient].globalPropertiesDictionary = @{@"platform": @"ios"};
    NSString *projectId = nil;
    NSString *writeKey = nil;
    NSString *readKey = nil;
#if PRD
    // Production
    projectId = @"518194e13843312d5e000000";
    writeKey = @"dbb742890496850659fa1a8607c2f679ad02268865ddcaecdb7756cc447f62fccd8dd008bb6d867b1895b13d03eaced39d5c32469c750bef199fb4a4cc7d3f408a358a79af6ddaf73256fafd4a4a89ff871df72177846b2b085fef3c0d6badc31154150243b87987a750fc7a1e171217";
    readKey = @"e5c4cca463c1b014077482bb36f989ec1fcd0d6ffe5acbd62723f6f19ce14c10c35640953e6be444f338ceb26e60f411e37620a3fe3a9dd598764ddd70faeab9c91534dbdfe3311f6b3e1e92f818b90adf131084e5c9fe9276d85242cfba083ecc8386bca7153290fb340ab12118c9a0";
#else
    // Dev
    projectId = @"51819044897a2c5208000002";
    writeKey = @"9a7a581d1e0066db50049c2a117fddeee6309d0af4337eeccaaac21e5eb0d70b38df151e11e6c80912c16f7d63dcfc965a89a62b875e9d29e822859ddbb09f164399cab4b7c92603ae5cb6c69542850a149129814bec617e26beaeb030a863ad21ce9f1ba25b727c08a1b932018fb111";
    readKey = @"ae051361b48f48df15bb52c1efc975e14cc8506cf07ae37bd5523c733e5c65a77dd7003e6888abd74640b968bde946812b1bab292ee109468177abb20881d77a850d8ad836383630b8da7090f0137ff24b99effa1f2b3b80b436d52a3156fce10229695bb70776a11487c7860af39328";
#endif
    [KeenClient sharedClientWithProjectId:projectId andWriteKey:writeKey andReadKey:readKey];
}

+ (void)addEvent:(NSDictionary*)event toEventCollection:eventCollection
{
    return;
    
//    JNLog(@"%@\n%@", eventCollection, event);
    [[KeenClient sharedClient] addEvent:event toEventCollection:eventCollection error:nil];
}

+ (void)uploadEventMetricsWithApplication:(UIApplication*)application
{
    return;
    
    UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        JNLog(@"Background task is being expired.");
    }];
    
    [[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
        [application endBackgroundTask:taskId];
    }];
}

@end
