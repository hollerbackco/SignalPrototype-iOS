//
//  SGSession.m
//  HollerbackApp
//
//  Created by Jeffrey Noh on 10/1/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <JDStatusBarNotification.h>

#import "JNAppManager.h"

#import "SGSession.h"
#import "SGAPIClient.h"
#import "SGVideodata.h"
#import "SGDatabase.h"
#import "JNSimpleDataStore.h"
#import "SGUser.h"
#import "SGUser+Service.h"
//#import "SGMetrics.h"
#import "SGStatusBarNotification.h"
#import "SGSchemaAppVersion+Service.h"
#import "SGMetrics.h"

#define kSGSignUpPasswordKey @"kSGSignUpPasswordKey"

dispatch_queue_t syncQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("syncQueue", 0);
    });
    return queue;
}

void runOnSyncQueue(void (^block)(void))
{
    dispatch_async(syncQueue(), block);
}

@interface SGSession ()

@property (strong, nonatomic) SGDatabase *database;
@property (strong, nonatomic) SGVideodata *videoData;

@end

@implementation SGSession

+(SGSession*) sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static SGSession* _singleton = nil;
    
    dispatch_once(&p, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

+ (void)setVideoPlaybackStartDate:(NSDate*)date
{
    if ([NSDate isNotNullDate:date]) {
        [JNSimpleDataStore setValue:date forKey:SGVideoPlaybackStart];
    } else {
        [JNSimpleDataStore setValue:nil forKey:SGVideoPlaybackStart];
    }
}

+ (NSDate*)getVideoPlaybackStartDate
{
    NSDate *videoPlaybackStartDate = (NSDate*) [JNSimpleDataStore getValueForKey:SGVideoPlaybackStart];
    if ([NSDate isNotNullDate:videoPlaybackStartDate]) {
        return videoPlaybackStartDate;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _videoData = [SGVideodata sharedInstance];
        _appState = SGAppStateNone;
    }
    return self;
}

- (void)startFromAppLaunch
{
    JNLogObject([NSThread callStackSymbols]);
    
    // check schema app version
    BOOL isSchemaAppVersionExpired = [SGSchemaAppVersion isSchemaAppVersionExpired];
    JNLogPrimitive(isSchemaAppVersionExpired);

    if (isSchemaAppVersionExpired) {
        [self rebuildAppData];
    } else {
        // update schema app version table
        [SGSchemaAppVersion updateLatestAppVersion:[JNAppManager getAppVersion]];
    }
}

- (void)start
{
    JNLogObject([NSThread callStackSymbols]);
    
	[self rebuildAppData];
}

- (void)rebuildAppData
{
    JNLog();
    // rebuild tables
	[SGDatabase resetAllTables];
    // clear last updated
    [JNSimpleDataStore setValue:nil forKey:kSGConversationsLastUpdatedAt];
    // update schema app version table
    [SGSchemaAppVersion updateLatestAppVersion:[JNAppManager getAppVersion]];
}

- (void)endSession
{
    JNLog();
}

- (void)restart
{
    JNLog();
    if([self isLoggedIn]) {
        self.isSyncing = @(YES);
        [self syncWithRemoteCompleted:nil];
    }
}

- (void)didStartPlayback
{
    JNLog();
    // suspend all download operations
	[self.videoData.syncQueue setSuspended:YES];
    self.appState = SGAppStatePlayback;
}

- (void)didFinishPlayback
{
    JNLog();
    self.appState = SGAppStateNone;
}

- (void)didStartRecording
{
    JNLog();
    if (self.isInWelcomeFlow) {
        self.appState = SGAppStateWelcomeFlowRecording;
    } else {
        self.appState = SGAppStateRecording;
    }
}

- (void)didFinishRecording
{
    JNLog();
    // start download operations
	[self.videoData.syncQueue setSuspended:NO];
    if (self.appState == SGAppStateRecording) {
        self.appState = SGAppStateNone;
    } else if (self.appState == SGAppStateWelcomeFlowRecording) {
        self.appState = SGAppStateWelcomeFlow;
    }
}

- (void)syncWithRemoteCompleted:(void(^)())completed
{
    runOnSyncQueue(^{
        JNLogPrimitive(self.isSyncing.boolValue);
        self.isSyncing = @(YES);
        
        [SGStatusBarNotification showSyncing];
        
        [self.videoData syncWithCompleteBlock:^{
            JNLog(@"SYNC'D FOR APP LAUNCH");
            [SGStatusBarNotification dismiss];
            self.isSyncing = @(NO);
            
            if (completed) completed();
        }];
    });
}

- (void)registerWithEmail:(NSString*)email
                 password:(NSString*)password
                 username:(NSString*)username
                    phone:(NSString*)phone
                  success:(SGSessionSuccessBlock)success
                     fail:(SGSessionFailBlock)fail
{
    // device token
    NSString *deviceToken = [self getDeviceToken];
    
    [[SGAPIClient sharedClient]
     signUpWithEmail:email
     password:password
     name:username
     phone:phone
     deviceToken:deviceToken
     cohort:nil
     success:^(id object) {
         NSString *phoneNormalized = [((NSDictionary *)object) valueForKeyPath:@"user.phone_normalized"];
         if ([NSString isNotEmptyString:phoneNormalized]) {
             success(object);
         } else {
             fail(JNLocalizedString(@"failed.request.alert.body"));
         }
     } fail:^(NSString *errorMessage) {
         [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
         fail(JNLocalizedString(@"failed.request.alert.body"));
     }];
}

- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
               success:(SGSessionSuccessBlock)success
                  fail:(SGSessionFailBlock)fail
{
    // device token
    NSString *deviceToken = [self getDeviceToken];
    
    [[SGAPIClient sharedClient] signInWithEmail:email password:password deviceToken:deviceToken success:^(id object) {
        NSString *phoneNormalized = [((NSDictionary *)object) valueForKeyPath:@"user.phone_normalized"];
        if ([NSString isNotEmptyString:phoneNormalized]) {
            NSString *accessToken = [((NSDictionary *)object) valueForKeyPath:@"user.access_token"];
            JNLogObject(accessToken);
            [self createSessionWithAccessToken:accessToken data:object];
            success(object);
        } else {
            fail(JNLocalizedString(@"failed.request.alert.body"));
        }
    } fail:^(NSString *errorMessage) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
        fail(JNLocalizedString(@"failed.request.alert.body"));
    }];
}

- (void)checkEmail:(NSString*)email
           success:(SGSessionSuccessBlock)success
              fail:(SGSessionFailBlock)fail
{
    [[SGAPIClient sharedClient] checkEmail:email success:^(id data) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            id free = [data objectForKey:@"free"];
            if ([NSNumber isNotNullNumber:free]) {
                if (((NSNumber*) free).boolValue) {
                    success(nil);
                } else {
                    NSString *message = (NSString*) [data objectForKey:@"message"];
                    fail(message);
                }
            } else {
                fail(@"There was a problem with checking your email. Please try again.");
            }
        } else {
            if ([NSNumber isNotNullNumber:data] &&
                ((NSNumber*) data).boolValue) {
                success(nil);
            } else {
                fail(@"There was a problem with checking your email. Please try again.");
            }
        }
    } fail:^(NSString *errorMessage) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
        fail(JNLocalizedString(@"failed.request.alert.body"));
    }];
}


- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
               password:(NSString*)password
                success:(SGSessionSuccessBlock)success
                   fail:(SGSessionFailBlock)fail
{
    // device token
    NSString *deviceToken = [self getDeviceToken];
    
    [[SGAPIClient sharedClient]
     verifyWithPhone:phone
     code:code
     deviceToken:deviceToken
     password:password
     success:^(id object) {
         NSString *accessToken = [((NSDictionary *)object) valueForKeyPath:@"user.access_token"];
         JNLogObject(accessToken);
         // reset any stored session data
         [self.class resetSessionDataAfterVerify];
         success(object);
         [self createSessionWithAccessToken:accessToken data:object];
         
     } fail:^(NSString *errorMessage) {
         [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
         fail(JNLocalizedString(@"failed.request.alert.body"));
     }];
}

-(void) createSessionWithAccessToken:(NSString*)accessToken data:(NSDictionary*)object
{
    JNLog();
    // ensure logged out
    [self logout];
    
    // save access_token
    [JNSimpleDataStore setValue:accessToken forKey:kSGAccessTokenKey];
    
    NSDictionary *userDict = [((NSDictionary *)object) valueForKeyPath:@"user"];
    NSError *error;
    SGUser *currentUser = [MTLJSONAdapter modelOfClass:SGUser.class fromJSONDictionary:userDict error:&error];
    if (!error) {
        [SGUser saveCurrentUser:currentUser];
    } else {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"could not init current user" error:error];
    }
}

- (NSString*)getDeviceToken
{
    // device token
    NSString *deviceToken = (NSString*) [JNSimpleDataStore getValueForKey:SGDeviceTokenKey];
    if (![NSString isNotEmptyString:deviceToken]) {
        JNLog(@"device token not found");
    }
    return deviceToken;
}

- (void)logout
{
    JNLog();
    [self start];
    
    // clear access token
    [JNSimpleDataStore setValue:nil forKey:kSGAccessTokenKey];
    
    // clear video pagination
    [JNSimpleDataStore deleteArchivedObject:SGVideoPaginationStoreKey];
    
    // clear user object
    [JNSimpleDataStore deleteArchivedObject:kSGCurrentUser];
    
    // clear stored data
    [JNSimpleDataStore setValue:nil forKey:kSGDidFinishWelcomeCreateConversationFlow];
    [JNSimpleDataStore setValue:nil forKey:kSGCreateConversationFlowMode];
}

- (BOOL)isLoggedIn
{
    NSString *accessToken = (NSString*) [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    JNLogObject(accessToken);
    return [NSString isNotEmptyString:accessToken];
}

#pragma mark - SGMosquittoNetReceiver

- (void) downstreamTransactionWithData:(NSData *)data
{
    JNLog(@"********* GOT NEW MESSAGE **********");
	//
//	NSError* error;
//    NSArray* json =    [NSJSONSerialization
//                        JSONObjectWithData: data //1
//                        options:            kNilOptions
//                        error:              &error];
//	
//    JNLogObject(json);
//	
//	[[SGVideodata sharedInstance] processSyncData:json onCompletion:^{
//        if ([NSDate isNotNullDate:[[SGVideodata sharedInstance] serverLastUpdated]]) {
//            [JNSimpleDataStore setValue:[[SGVideodata sharedInstance] serverLastUpdated]
//                               forKey:kSGConversationsLastUpdatedAt];
//        }
//	}];
    [self syncWithRemoteCompleted:nil];
}

#pragma mark - Onboarding

+ (void)didOnboardingActivity:(NSString*)onboardingActivity
{
    [self.class didOnboardingActivity:onboardingActivity parameters:nil];
}

+ (void)didOnboardingActivity:(NSString*)onboardingActivity parameters:(NSDictionary*)parameters
{
    NSNumber *didOnboardingActivity = (NSNumber*) [JNSimpleDataStore getValueForKey:onboardingActivity];
    JNLog(@"%@: %@", onboardingActivity, didOnboardingActivity);
    if ([NSNumber isNotANumber:didOnboardingActivity] ||
        !didOnboardingActivity.boolValue) {
        didOnboardingActivity = @(YES);
        [JNSimpleDataStore setValue:didOnboardingActivity forKey:onboardingActivity];
        // parameters
        NSMutableDictionary *mutableParameters = [@{SGSignUpSessionToken: [self.class generateSignUpSessionToken],
                                            kSGOnboardingVersionKey: @(kSGOnboardingVersion)} mutableCopy];
        if ([NSDictionary isNotNullDictionary:parameters]) {
            [mutableParameters addEntriesFromDictionary:parameters];
        }
        [SGMetrics addMetric:onboardingActivity withParameters:mutableParameters];
        // fire off metric event immediately
        [SGMetrics uploadMetrics];
    }
}

- (BOOL)isInWelcomeFlow
{
    JNLog();
    return self.appState == SGAppStateWelcomeFlow || self.appState == SGAppStateWelcomeFlowRecording;
}

- (void)didStartWelcomeFlow
{
    JNLog();
    self.appState = SGAppStateWelcomeFlow;
}

- (void)didFinishWelcomeFlow
{
    JNLog();
    JNLogPrimitive(self.appState);
    self.appState = SGAppStateNone;
}

#pragma mark - Sign up session

+ (void)storeSignUpPassword:(NSString*)password
{
    [JNSimpleDataStore setValue:password forKey:kSGSignUpPasswordKey];
}

+ (NSString*)getSignUpPassword
{
    return (NSString*) [JNSimpleDataStore getValueForKey:kSGSignUpPasswordKey];
}

+ (NSString*)generateSignUpSessionToken
{
    NSString *sessionToken = (NSString*) [JNSimpleDataStore getValueForKey:SGSignUpSessionToken];
    if ([NSString isNullOrEmptyString:sessionToken]) {
        JNLog(@"generating session token");
        CFUUIDRef uuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
        sessionToken = CFBridgingRelease(uuidString);
        [JNSimpleDataStore setValue:sessionToken forKey:SGSignUpSessionToken];
    }
    return sessionToken;
}

+ (void)didSignUpActivityForKey:(NSString*)key
{
    JNLogObject(key);
    NSNumber *didSignUpActivity = (NSNumber*) [JNSimpleDataStore getValueForKey:key];
    JNLogObject(didSignUpActivity);
    if ([NSNumber isNotANumber:didSignUpActivity] ||
        !didSignUpActivity.boolValue) {
        didSignUpActivity = @(YES);
        [JNSimpleDataStore setValue:didSignUpActivity forKey:key];
        [SGMetrics addMetric:key withObjectsAndKeys:
         [self.class generateSignUpSessionToken], SGSignUpSessionToken, nil];
        [SGMetrics uploadMetrics];
    }
}

#pragma mark - JNSimpleDataStore

+ (void)resetSessionDataAfterVerify
{
    JNLog();
    [JNSimpleDataStore setValue:nil forKey:SGFirstTimeWatchAndRespond];
    [JNSimpleDataStore setValue:nil forKey:SGFirstTimeStartingConversation];
    [JNSimpleDataStore setValue:@(YES) forKey:SGFirstTimeRecording];
    [JNSimpleDataStore setValue:@(YES) forKey:SGFirstTimeLoggedIn];
}

+ (BOOL)isFirstTimeForKey:(NSString*)key
{
    NSNumber *firstTime = (NSNumber*) [JNSimpleDataStore getValueForKey:key];
    if ([NSNumber isNotANumber:firstTime]) {
        firstTime = @(YES);
        [JNSimpleDataStore setValue:firstTime forKey:key];
    }
    return firstTime.boolValue;
}

+ (BOOL)isFirstTimeStartingConversation
{
    return [self.class isFirstTimeForKey:SGFirstTimeStartingConversation];
}

+ (void)setFirstTimeStartingConversation:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimeStartingConversation];
}    

+ (BOOL)isFirstTimeWatchAndRespond
{
    return [self.class isFirstTimeForKey:SGFirstTimeWatchAndRespond];
}

+ (void)setFirstTimeWatchAndRespond:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimeWatchAndRespond];
}

+ (BOOL)isFirstTimeLoggedIn
{
    return [self.class isFirstTimeForKey:SGFirstTimeLoggedIn];
}

+ (void)setFirstTimeLoggedIn:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimeLoggedIn];
}

+ (BOOL)isFirstTimeRecording
{
    return [self.class isFirstTimeForKey:SGFirstTimeRecording];
}

+ (void)setFirstTimeRecording:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimeRecording];
}

+ (BOOL)isFirstTimeEnteringFakeThread
{
    return [self.class isFirstTimeForKey:SGFirstTimeEnteringFakeThread];
}

+ (void)setIsFirstTimeEnteringFakeThread:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimeEnteringFakeThread];
}

+ (BOOL)isFirstTimePreRecording
{
    return [self.class isFirstTimeForKey:SGFirstTimePreRecording];
}

+ (void)setIsFirstTimePreRecording:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimePreRecording];
}

+ (BOOL)isFirstTimePostRecording
{
    return [self.class isFirstTimeForKey:SGFirstTimePostRecording];
}

+ (void)setIsFirstTimePostRecording:(BOOL)value
{
    [JNSimpleDataStore setValue:@(value) forKey:SGFirstTimePostRecording];
}


#pragma mark - Pagination

+ (void)setSyncLastMessageAt:(NSDate*)syncLastMessageAt
{
    [JNSimpleDataStore setValue:syncLastMessageAt forKey:SGSyncLastMessageAt];
}

+ (NSDate*)getSyncLastMessageAt
{
    return (NSDate*) [JNSimpleDataStore getValueForKey:SGSyncLastMessageAt];
}

#pragma mark - didFinishWelcomeCreateConversationFlow

- (void)setDidFinishWelcomeCreateConversationFlow:(BOOL)didFinishWelcomeCreateConversationFlow
{
    JNLog();
    [JNSimpleDataStore setValue:@(didFinishWelcomeCreateConversationFlow) forKey:kSGDidFinishWelcomeCreateConversationFlow];
}

- (BOOL)didFinishWelcomeCreateConversationFlow
{
    JNLog();
    NSNumber *didFinishWelcomeCreateConversationFlow = (NSNumber*) [JNSimpleDataStore getValueForKey:kSGDidFinishWelcomeCreateConversationFlow];
    if (didFinishWelcomeCreateConversationFlow) {
        return didFinishWelcomeCreateConversationFlow.boolValue;
    } else {
        [JNSimpleDataStore setValue:@(NO) forKey:kSGDidFinishWelcomeCreateConversationFlow];
        return NO;
    }
}

#pragma mark - createConversationFlowMode

- (void)setCreateConversationFlowMode:(NSUInteger)createConversationFlowMode
{
    JNLog();
    [JNSimpleDataStore setValue:@(createConversationFlowMode) forKey:kSGCreateConversationFlowMode];
}

- (NSUInteger)createConversationFlowMode
{
    JNLog();
    NSNumber *createConversationFlowMode = (NSNumber*) [JNSimpleDataStore getValueForKey:kSGCreateConversationFlowMode];
    if (createConversationFlowMode) {
        return createConversationFlowMode.unsignedIntegerValue;
    } else {
        [JNSimpleDataStore setValue:@(0) forKey:kSGCreateConversationFlowMode];
        return 0;
    }
}

@end
