//
//  SGSession.h
//  HollerbackApp
//
//  Created by Jeffrey Nohs on 10/1/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

void runOnSyncQueue(void (^block)(void));

typedef void (^SGSessionSuccessBlock)(id data);
typedef void (^SGSessionFailBlock)(NSString *errorMessage);

typedef enum {
    SGAppStateNone,
    SGAppStateWelcomeFlow,
    SGAppStateWelcomeFlowRecording,
    SGAppStatePlayback,
    SGAppStateRecording
} SGAppState;

@interface SGSession : NSObject

@property (nonatomic) SGAppState appState;
@property (nonatomic, strong) NSNumber *isSyncing;
@property (nonatomic) BOOL didFinishWelcomeCreateConversationFlow;
@property (nonatomic) NSUInteger createConversationFlowMode;

+ (SGSession*) sharedInstance;

+ (void)setVideoPlaybackStartDate:(NSDate*)date;
+ (NSDate*)getVideoPlaybackStartDate;

// clean and rebuild the conversation tables and resync
- (void)startFromAppLaunch;
// clean and rebuild all tables and resync
- (void)start;

// syncs session and starts mqtt
- (void)restart;

- (void)endSession;

// sync with remote
- (void)syncWithRemoteCompleted:(void(^)())completed;

- (void)didStartPlayback;
- (void)didFinishPlayback;
- (void)didStartRecording;
- (void)didFinishRecording;

- (void)registerWithEmail:(NSString*)email
                 password:(NSString*)password
                 username:(NSString*)username
                    phone:(NSString*)phone
                  success:(SGSessionSuccessBlock)successBlock
                     fail:(SGSessionFailBlock)failBlock;
- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
               password:(NSString*)password
                success:(SGSessionSuccessBlock)successBlock
                   fail:(SGSessionFailBlock)failBlock;
- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
               success:(SGSessionSuccessBlock)success
                  fail:(SGSessionFailBlock)fail;
- (void)checkEmail:(NSString*)email
           success:(SGSessionSuccessBlock)success
              fail:(SGSessionFailBlock)fail;

- (void)logout;
- (BOOL)isLoggedIn;

#pragma mark - Onboarding

+ (void)didOnboardingActivity:(NSString*)onboardingActivity;
+ (void)didOnboardingActivity:(NSString*)onboardingActivity parameters:(NSDictionary*)parameters;
- (BOOL)isInWelcomeFlow;
- (void)didStartWelcomeFlow;
- (void)didFinishWelcomeFlow;

#pragma mark - Sign up session

+ (void)storeSignUpPassword:(NSString*)password;
+ (NSString*)getSignUpPassword;
+ (NSString*)generateSignUpSessionToken;
+ (void)didSignUpActivityForKey:(NSString*)key;

#pragma mark - JNSimpleDataStore

+ (BOOL)isFirstTimeStartingConversation;
+ (void)setFirstTimeStartingConversation:(BOOL)value;

+ (BOOL)isFirstTimeWatchAndRespond;
+ (void)setFirstTimeWatchAndRespond:(BOOL)value;

+ (BOOL)isFirstTimeLoggedIn;
+ (void)setFirstTimeLoggedIn:(BOOL)value;

+ (BOOL)isFirstTimeRecording;
+ (void)setFirstTimeRecording:(BOOL)value;

+ (BOOL)isFirstTimeEnteringFakeThread;
+ (void)setIsFirstTimeEnteringFakeThread:(BOOL)value;

+ (BOOL)isFirstTimePreRecording;
+ (void)setIsFirstTimePreRecording:(BOOL)value;

+ (BOOL)isFirstTimePostRecording;
+ (void)setIsFirstTimePostRecording:(BOOL)value;

#pragma mark - Pagination

+ (void)setSyncLastMessageAt:(NSDate*)syncLastMessageAt;
+ (NSDate*)getSyncLastMessageAt;

@end
