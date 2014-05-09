//
//  SGSchemaAppVersion+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 6/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNAppManager.h"

#import "SGSchemaAppVersion.h"

@interface SGSchemaAppVersion (Service)

+ (NSString*)getLatestAppVersion;

+ (void)updateLatestAppVersion:(NSString*)appVersion;

+ (BOOL)isSchemaAppVersionExpired;

+ (BOOL)isAppVersion:(NSString*)appVersion1 earlierThanAppVersion:(NSString*)appVersion2;

@end
