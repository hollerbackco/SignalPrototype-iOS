//
//  HBPushNotificationHandler.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 18/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBPushNotificationHandler : NSObject

@property (nonatomic) BOOL willEnterFromPush;
@property (nonatomic, strong) NSNumber *pushToConversationID;

#pragma mark - Singleton

+ (HBPushNotificationHandler*)sharedInstance;

+ (BOOL)didAttemptToRegisterPushNotifications;

+ (void)registerForPushNotificationsCompleted:(void(^)())completed denied:(void(^)())denied;

+ (void)failedToRegisterForPushNotifications;

#pragma mark - Class methods

+ (NSString*)generateHexToken:(NSData*)deviceToken;

#pragma mark - 

- (void)handlePushFromLaunchOptions:(NSDictionary*)launchOptions;

- (void)handlePushPayload:(NSDictionary*)payload;

- (void)startAllowPushFlowInViewController:(UIViewController*)viewController completed:(void(^)())completed;

@end
