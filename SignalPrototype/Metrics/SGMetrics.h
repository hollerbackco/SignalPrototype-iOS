//
//  SGMetrics.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSGFlurryEventVideoSent @"kSGFlurryEventVideoSent"
#define kSGFlurryEventTextMessageSent @"kSGFlurryEventTextMessageSent"
#define kSGFlurryEventInviteSentAfterNewConversation @"kSGFlurryEventInviteSentAfterNewConversation"
#define kSGFlurryEventInviteSentFromSMS @"kSGFlurryEventInviteSentFromSMS"
#define kSGFlurryEventInviteSentFromEmail @"kSGFlurryEventInviteSentFromEmail"

@interface SGMetrics : NSObject

+ (void)addMetric:(NSString*)name;
+ (void)addMetric:(NSString*)name withObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)addMetric:(NSString *)name withParameters:(NSDictionary*)parameters;
+ (void)uploadMetrics;

+ (void)logFlurryEvent:(NSString*)eventName;

@end

#pragma mark - Keen

@interface SGMetrics (Keen)

+ (void)setupMetrics;
+ (void)addEvent:(NSDictionary*)event toEventCollection:eventCollection;
+ (void)uploadEventMetricsWithApplication:(UIApplication*)application;

@end
