//
//  JNAppManager.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

// necessary for determine iphone model
#include <sys/types.h>
#include <sys/sysctl.h>

#import "JNAppManager.h"

#define kJNiPhoneHeight3_5inch 480.0

@implementation JNAppManager

+ (NSString*)getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)modelName
{
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

+ (BOOL)canUseFaceDetection
{
    return ![self.class deviceHasA4ChipOrSlower];
}

+ (BOOL)deviceHasA4ChipOrSlower
{
    return [self.class deviceHasA4ChipOrSlower:[self.class modelName]];
}

+ (BOOL)deviceHasA4ChipOrSlower:(NSString*)modelName
{
    if ([modelName isEqualToString:@"iPhone 2G"]
        || [modelName isEqualToString:@"iPhone 3G"]
        || [modelName isEqualToString:@"iPhone 3GS"]
        || [modelName isEqualToString:@"iPhone 4"]
        || [modelName isEqualToString:@"iPhone 4 (CDMA)"]
        || [modelName isEqualToString:@"iPod Touch (1 Gen)"]
        || [modelName isEqualToString:@"iPod Touch (2 Gen)"]
        || [modelName isEqualToString:@"iPod Touch (3 Gen)"]
        || [modelName isEqualToString:@"iPod Touch (4 Gen)"]
        || [modelName isEqualToString:@"iPad"]
        || [modelName isEqualToString:@"iPad 3G"])
    {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)is3_5InchScreenSize
{
    return [UIScreen mainScreen].bounds.size.height == kJNiPhoneHeight3_5inch;
}

+ (void)printAppState
{
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateInactive:
            JNLog(@"UIApplicationStateInactive");
            break;
        case UIApplicationStateActive:
            JNLog(@"UIApplicationStateActive");
            break;
        case UIApplicationStateBackground:
            JNLog(@"UIApplicationStateBackground");
            break;
        default:
            break;
    }
}

@end
