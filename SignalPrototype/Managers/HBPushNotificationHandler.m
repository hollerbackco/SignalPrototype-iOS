//
//  HBPushNotificationHandler.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 18/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "JNSimpleDataStore.h"
#import "JNAlertView.h"

#import "SGConversationsViewController.h"

#import "HBPushNotificationHandler.h"
#import "HBWelcomeAllowPushViewController.h"
#import "HBWelcomeFlow.h"

@implementation HBPushNotificationHandler

#pragma mark - Singleton

static HBPushNotificationHandler *sharedInstance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedInstance = [[HBPushNotificationHandler alloc] init];
    }
}

+ (HBPushNotificationHandler*)sharedInstance
{
    return sharedInstance;
}

+ (BOOL)didAttemptToRegisterPushNotifications
{
    // flag to determine if user has previously been asked permissions for push
    NSNumber *didAttemptToRegisterPushNotifications = (NSNumber*) [JNSimpleDataStore getValueForKey:SGDidAttemptToRegisterPushNotifications];
    return didAttemptToRegisterPushNotifications && didAttemptToRegisterPushNotifications.boolValue;
}

+ (void)registerForPushNotificationsCompleted:(void(^)())completed denied:(void(^)())denied
{
    UIRemoteNotificationType remoteNotificationsTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    JNLogPrimitive([self.class didAttemptToRegisterPushNotifications]);
    if ([self.class didAttemptToRegisterPushNotifications]) {
        // have previously attempted to ask use for push, see if they're granted or denied
        UIRemoteNotificationType enabledRemoteNotificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (enabledRemoteNotificationTypes != remoteNotificationsTypes) {
            if (denied) {
                denied();
            } else {
                [self failedToRegisterForPushNotifications];
            }
        } else {
            if (completed) {
                completed();
            }
        }
    } else {
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteNotificationsTypes];
        // store flag to say we've attempted to register for push
        [JNSimpleDataStore setValue:@(YES) forKey:SGDidAttemptToRegisterPushNotifications];
        if (completed) {
            completed();
        }
    }
}

+ (void)failedToRegisterForPushNotifications
{
    JNLog();
    runOnMainQueue(^{
        [JNAlertView showWithTitle:@"Oops." body:NSLocalizedString(@"Failed to register push", nil)];
    });
}

#pragma mark - Class methods

+ (NSString*)generateHexToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];    
    NSString *hexToken = [NSString stringWithFormat:@"%08x %08x %08x %08x %08x %08x %08x %08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    JNLog(@"hexToken: %@", hexToken);
    return hexToken;
}

#pragma mark -

- (void)handlePushFromLaunchOptions:(NSDictionary*)launchOptions
{
    NSAssert(launchOptions, @"launchOptions not found");
    NSDictionary* remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification && [remoteNotification isKindOfClass:[NSDictionary class]]) {
        [self handlePushPayload:remoteNotification];
    }
}

- (void)handlePushPayload:(NSDictionary*)payload
{
    JNLog();
    @try {
        // set badge number
        NSDictionary *aps = [payload objectForKey:@"aps"];
        if (aps && [aps isKindOfClass:[NSDictionary class]]) {
            NSNumber *badgeNumber = [aps objectForKey:@"badge"];
            if (badgeNumber && [badgeNumber isKindOfClass:[NSNumber class]]) {
                [self setBadgeNumber:badgeNumber.integerValue];
            }
        }
        NSNumber *conversationID = [payload objectForKey:@"conversation_id"];
        if ([NSNumber isNotNullNumber:conversationID]) {
            self.willEnterFromPush = YES;
            self.pushToConversationID = conversationID;
        }
    }
    @catch (NSException *exception) {
        [JNLogger logException:exception];
    }
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
}

- (void)startAllowPushFlowInViewController:(UIViewController*)viewController
{
    JNLog();
    runOnMainQueue(^{
        
        HBWelcomeAllowPushViewController *welcomeAllowPushViewController = [[HBWelcomeAllowPushViewController alloc] initWithNib];
        welcomeAllowPushViewController.contentTitle = JNLocalizedString(@"welcome.allow.push.logged.in.title");
        [viewController presentViewController:welcomeAllowPushViewController animated:YES completion:nil];
        
        @weakify(viewController);
        welcomeAllowPushViewController.finishedViewController = ^() {
            [HBPushNotificationHandler registerForPushNotificationsCompleted:^{
                [self finishedRegisteringForPushInViewController:viewController_weak_];
            } denied:^{
                [self finishedRegisteringForPushInViewController:viewController_weak_];
            }];
        };
    });
}

- (void)finishedRegisteringForPushInViewController:(UIViewController*)viewController
{
    JNLog();
    runOnMainQueue(^{
        [viewController dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
