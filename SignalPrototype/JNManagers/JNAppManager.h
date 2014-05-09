//
//  JNAppManager.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNAppManager : NSObject

+ (NSString*)getAppVersion;

+ (NSString*)modelName;

+ (BOOL)canUseFaceDetection;

+ (BOOL)deviceHasA4ChipOrSlower;

+ (BOOL)is3_5InchScreenSize;

+ (void)printAppState;

@end
