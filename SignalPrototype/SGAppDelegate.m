//
//  SGAppDelegate.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 8/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import <EXTScope.h>

#import "JNSimpleDataStore.h"

#import "SGAppDelegate.h"
#import "SGSession.h"
#import "SGCreateThreadViewController.h"
#import "SGInitialViewController.h"
#import "SGUser+Service.h"

#import "HBWelcomeFlow.h"
#import "HBPushNotificationHandler.h"

@interface SGAppDelegate ()

@property (nonatomic, strong) UINavigationController *conversationsNavigationController;
@property (nonatomic, strong) SGCreateThreadViewController *createThreadViewController;

@property (nonatomic, strong) UINavigationController *accountNavigationController;
@property (nonatomic, strong) SGInitialViewController *initialViewController;

@property (nonatomic, strong) HBWelcomeFlow *welcomeFlow;

@end

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setupRootViewController];
    
    return YES;
}

#pragma mark - Root View Controller

- (void)setupRootViewController
{
    if ([[SGSession sharedInstance] isLoggedIn]) {
        
        [self setupConversationsRootViewController];
        
    } else {
        
        [self startWelcomeFlow];
    }
}

- (void)setupConversationsRootViewController
{
    JNLog();
    // register for push
    [HBPushNotificationHandler registerForPushNotificationsCompleted:^{
        
        [self showConversationsViewController];
        
    } denied:^{
        
        [JNAlertView
         showWithTitle:JNLocalizedString(@"welcome.allow.push.denied.alert.title")
         body:JNLocalizedString(@"welcome.allow.push.denied.alert.body")
         okAction:^{
             [self showConversationsViewController];
         }];
        
    }];
}

- (void)showConversationsViewController
{
    if (!self.createThreadViewController) {
        self.createThreadViewController = [[SGCreateThreadViewController alloc] initWithNib];
    }
    
    if (!self.conversationsNavigationController) {
        self.conversationsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.createThreadViewController];
    }
    
    self.window.rootViewController = self.conversationsNavigationController;
}

#pragma mark - Logger

- (void)setupLogger
{
    // configure logger
    [[JNLogger sharedInstance] configureFileLogger];
}

#pragma mark - Welcome Flow

- (void)startWelcomeFlow
{
    JNLog();
    [[SGSession sharedInstance] didStartWelcomeFlow];

    self.welcomeFlow = [HBWelcomeFlow new];
    [self.welcomeFlow startWelcomeFlowCompleted:nil];
    self.window.rootViewController = self.welcomeFlow.welcomeStartNavigationController;
    // go to login
    @weakify(self);
    self.welcomeFlow.didLoginBlock = ^() {
        
        [self_weak_ setupRootViewController];
        // check for push registration
        [self_weak_ checkForPushRegistration];
    };
    self.welcomeFlow.finishWelcomeFlowBlock = ^() {
        
        [self_weak_ setupRootViewController];
    };
}

#pragma mark - Application Background / Active

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Remote Notifications (Push)

- (void)checkForPushRegistration
{
    if ([HBPushNotificationHandler didAttemptToRegisterPushNotifications]) {
        JNLogPrimitive([HBPushNotificationHandler didAttemptToRegisterPushNotifications]);
        [[HBPushNotificationHandler sharedInstance] startAllowPushFlowInViewController:self.createThreadViewController];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *hexToken = [HBPushNotificationHandler generateHexToken:deviceToken];
    JNLogObject(hexToken);
    NSString *storedDeviceToken = (NSString*) [JNSimpleDataStore getValueForKey:SGDeviceTokenKey];
    JNLogObject(storedDeviceToken);
    if (![NSString isNotEmptyString:storedDeviceToken]) {
        [SGUser updateDeviceTokenForCurrentUser:hexToken completed:^{
            JNLog(@"completed");
        } failed:^{
            JNLog(@"failed");
        }];
    }
    // store device token
    [JNSimpleDataStore setValue:hexToken forKey:SGDeviceTokenKey];
    // log metric
    [SGSession didOnboardingActivity:kSGOnboardingPush
                          parameters:@{kSGOnboardingAllowedKey:@(YES)}];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	JNLog(@"Failed to get token, error: %@", error);
    [HBPushNotificationHandler failedToRegisterForPushNotifications];
    // log metric
    [SGSession didOnboardingActivity:kSGOnboardingPush
                          parameters:@{kSGOnboardingAllowedKey:@(NO)}];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    JNLog(@"application.applicationState: %@, userInfo: %@",@(application.applicationState), userInfo);
    // save push payload info
    [[HBPushNotificationHandler sharedInstance] handlePushPayload:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    JNLog(@"application.applicationState: %@, userInfo: %@",@(application.applicationState), userInfo);
    
    // save push payload info
    [[HBPushNotificationHandler sharedInstance] handlePushPayload:userInfo];
    
    // sync with remote
    [[SGSession sharedInstance] syncWithRemoteCompleted:^{
        JNLog(@"sync completed");
    }];
}

@end
