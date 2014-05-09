//
//  SGAPIClient.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "NSString+MD5.h"

#import "JNAppManager.h"

#import "SGAPIClient.h"
#import "JNSimpleDataStore.h"
#import "SGMetrics.h"

@interface SGAPIClient ()

@property (nonatomic) UIBackgroundTaskIdentifier taskId;

@end

@implementation SGAPIClient

#pragma mark - Class methods

+ (SGAPIClient *)sharedClient {
    static SGAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SGAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kSGAPIBasePath]];
    });
    
    return _sharedClient;
}

+ (NSDictionary*)createAccessTokenParameter
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"nil accessToken");
        return @{};
    } else {
        return @{@"access_token": accessToken};
    }
}

#pragma mark - Init

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestSerializer setValue:kSGRequestHeaderAPIVersion forHTTPHeaderField:kSGRequestHeaderAccept];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    return self;
}

#pragma mark - Background Tasks

- (void)beginBackgroundTask
{
    // run on as bg task if in bg
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        if (self.taskId == UIBackgroundTaskInvalid) {
            self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
                JNLog(@"Background task is being expired.");
            }];
        } else {
            JNLog(@"already running in bg task");
        }
    }
}

- (void)endBackgroundTask
{
    if (self.taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
        self.taskId = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Requests

- (void)handleOperation:(AFHTTPRequestOperation*)operation
              eventType:(NSString*)eventType
         responseObject:(id)responseObject
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail
{
    @try {
        //            JNLog(@"SUCCESS jsonResponse: %@", responseObject);
        id meta = [responseObject objectForKey:@"meta"];
        if (meta) {
            NSString *errorMessage = [meta objectForKey:@"msg"];
            if (errorMessage && [errorMessage isKindOfClass:[NSString class]] && errorMessage.length == 0) {
                fail(errorMessage);
                return;
            }
            id errors = [meta objectForKey:@"errors"];
            if (errors) {
                JNLog(@"%@\n%@", [NSThread callStackSymbols], errors);
                fail(@"Errors found. Please try again.");
                return;
            }
        }
    }
    @catch (NSException *exception) {
        [JNLogger logException:exception];
    }
    success(responseObject);
}

- (void)handleError:(NSString*)errorMessage eventType:(NSString*)eventType params:(NSDictionary*)params
{
    // upload log file to s3
    if (errorMessage && params)
        [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
    else
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"" error:nil];
}

- (void)handleAccessToken:(NSString*)accessToken
                eventType:(NSString*)eventType
           responseObject:(id)responseObject
                  success:(SGAPIClientSuccessBlock)successBlock
                     fail:(SGAPIClientFailBlock)failBlock
{
    if (accessToken && [accessToken isNotNullString]) {
        successBlock(accessToken);
        // TODO: update country code!
        [JNSimpleDataStore setValue:@"1" forKey:SGCountryCodeKey];
    } else {
        NSString *errorMessage = @"Missing access_token.";
        [self handleError:errorMessage eventType:[NSString stringWithFormat:@"%@_Error", eventType] params:@{@"responseObject": responseObject}];
        failBlock(errorMessage);
    }
}

- (void)setPlatformParameter:(NSMutableDictionary*)parameters
{
    if (parameters && [parameters isKindOfClass:[NSMutableDictionary class]]) {
        [parameters setValue:kSGAPIPlatform forKey:@"platform"];
    }
}

- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
            deviceToken:(NSString*)deviceToken
               password:(NSString*)password
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    // add params
    if ([NSString isNotEmptyString:phone])
        [parameters setValue:phone forKey:@"phone"];
    if ([NSString isNotEmptyString:code])
        [parameters setValue:code forKey:@"code"];
    if ([NSString isNotEmptyString:deviceToken])
        [parameters setValue:deviceToken forKey:@"device_token"];
    if ([NSString isNotEmptyString:password])
        [parameters setValue:password forKey:@"password"];
    
    [self POST:@"verify" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:@"verify"].location != NSNotFound) {
            [self handleOperation:operation eventType:@"Verify" responseObject:responseObject success:^(id object) {
                if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
                    success(object);
                } else {
                    fail(@"There was a problem verifying the number. Please try again.");
                }
            } fail:^(NSString *errorMessage) {
                fail(errorMessage);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        [self handleAuthRequestFailure:operation fail:fail];
        return;
    }];
}

- (void)checkEmail:(NSString*)email
           success:(SGAPIClientSuccessBlock)success
              fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    // add params
    if ([NSString isNotEmptyString:email])
        [parameters setValue:email forKey:@"email"];
    
    [self POST:@"email/available" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:@"email/available"].location != NSNotFound) {
            [self handleOperation:operation eventType:@"EmailAvailable" responseObject:responseObject success:^(id object) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    id data = [object objectForKey:@"data"];
                    success(data);
                } else {
                    fail(@"There was a problem checking the email.");
                }
            } fail:^(NSString *errorMessage) {
                fail(errorMessage);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        [self handleAuthRequestFailure:operation fail:fail];
        return;
    }];
}

- (void)sendPinWithPhone:(NSString*)phone
                 success:(SGAPIClientSuccessBlock)success
                    fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    // add params
    if ([NSString isNotEmptyString:phone])
        [parameters setValue:phone forKey:@"phone"];
    
    [self POST:@"session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:@"session"].location != NSNotFound) {
            [self handleOperation:operation eventType:@"Send Pin" responseObject:responseObject success:^(id object) {
                if (![object isKindOfClass:[NSDictionary class]] && ![object isKindOfClass:[NSArray class]]) {
                    fail(@"Phone number not found. Please try again.");
                    return;
                }
//                NSString *accessToken = [((NSDictionary *)object) valueForKeyPath:@"user.access_token"];
//                if (![NSString isNotEmptyString:accessToken]) {
//                    fail(@"There was a problem sending the pin. Please try again.");
//                    return;
//                }
                success(object);
            } fail:fail];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        [self handleAuthRequestFailure:operation fail:fail];
        return;
    }];
}

- (void)handleAuthRequestFailure:(AFHTTPRequestOperation*)operation fail:(SGAPIClientFailBlock)fail
{
    if ((operation.response.statusCode > 399 || operation.response.statusCode < 500) &&
        [operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        id response = operation.responseObject;
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSString *errorMessage = [response valueForKeyPath:@"meta.msg"];
            fail(errorMessage);
        } else {
            fail(@"Failed to send off request. Please try again.");
        }
    } else {
        fail(@"Failed to send off request. Please try again.");
    }
}


// OLD SIGN IN / SIGN UP CODE //

- (void)signInWithEmail:(NSString*)email
               password:(NSString*)password
            deviceToken:(NSString*)deviceToken
                success:(SGAPIClientSuccessBlock)successBlock
                   fail:(SGAPIClientFailBlock)failBlock
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    // add params
    if (email && [email isNotNullString])
        [parameters setValue:email forKey:@"email"];
    if (password && [password isNotNullString])
        [parameters setValue:password forKey:@"password"];
    if (deviceToken && [deviceToken isNotNullString])
        [parameters setValue:deviceToken forKey:@"device_token"];
    // must include client platform
    [self setPlatformParameter:parameters];
    
    [self POST:@"session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:@"session"].location != NSNotFound) {
            [self handleOperation:operation eventType:@"Sign_In" responseObject:responseObject success:^(id object) {
                if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
                    NSString *accessToken = [((NSDictionary *)object) valueForKeyPath:@"user.access_token"];
                    if (![NSString isNotEmptyString:accessToken]) {
                        failBlock(@"There was a problem sending the pin. Please try again.");
                        return;
                    }
                    successBlock(object);
                } else {
                    failBlock(@"Response object not recognized.");
                }
            } fail:failBlock];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        [self handleAuthRequestFailure:operation fail:failBlock];
        return;
    }];
}

- (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
                   name:(NSString*)name
                  phone:(NSString*)phone
            deviceToken:(NSString*)deviceToken
                 cohort:(NSString*)cohort
                success:(SGAPIClientSuccessBlock)successBlock
                   fail:(SGAPIClientFailBlock)failBlock
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    // add params
    if (email && [email isNotNullString])
        [parameters setValue:email forKey:@"email"];
    if (password && [password isNotNullString])
        [parameters setValue:password forKey:@"password"];
    if (name && [name isNotNullString])
        [parameters setValue:name forKey:@"username"];
    if (phone && [phone isNotNullString]) {
        [parameters setValue:phone forKey:@"phone"];
        NSString *phoneHashed = [phone MD5String];
        [parameters setValue:phoneHashed forKey:@"phone_hashed"];
    }
    if (deviceToken && [deviceToken isNotNullString]) {
        [parameters setValue:deviceToken forKey:@"device_token"];
    }
    if ([NSString isNotEmptyString:cohort]) {
        [parameters setObject:cohort forKey:@"cohort"];
    }
    
    // must include client platform
    [self setPlatformParameter:parameters];
    
    [self POST:@"register" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:@"register"].location != NSNotFound) {
            [self handleOperation:operation eventType:@"Sign_Up" responseObject:responseObject success:^(id object) {
                if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
                    successBlock(object);
                } else {
                    failBlock(@"There was a problem verifying the number. Please try again.");
                }
            } fail:^(NSString *errorMessage) {
                failBlock(errorMessage);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        [self handleAuthRequestFailure:operation fail:failBlock];
        return;
    }];
}

- (void)logoutWithAccessToken:(NSString*)accessToken
                      success:(SGAPIClientSuccessBlock)successBlock
                         fail:(SGAPIClientFailBlock)failBlock
{
    if (!accessToken || ![accessToken isNotNullString]) {
        [JNLogger logException:[NSException exceptionWithName:THIS_METHOD reason:@"missing access token" userInfo:nil]];
        failBlock(@"missing access token");
        return;
    }
    NSMutableDictionary *parameters = [@{} mutableCopy];
    if (accessToken && [accessToken isNotNullString]) {
        [parameters setValue:accessToken forKey:@"access_token"];
    }
    [self DELETE:@"session/ios" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLog(@"responseObject: %@", responseObject);
        successBlock(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logException:[NSException exceptionWithName:THIS_METHOD reason:@"could not log out" userInfo:@{@"operation": operation, @"error": error}]];
        // continue logout even if failed.
        failBlock(nil);
    }];
}

- (void)clearUnwatchedVideos:(NSNumber*)conversationId
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!conversationId || !accessToken) {
        fail(@"Missing conversationId or access_token parameters.");
        return;
    }
    // params
    NSDictionary *parameters = @{@"access_token": accessToken};
    NSString *clearUnwatchedVideosPath = [NSString stringWithFormat:@"me/conversations/%@/watch_all", conversationId];
    [self POST:clearUnwatchedVideosPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.request.URL.absoluteString rangeOfString:clearUnwatchedVideosPath].location != NSNotFound) {
            [self handleOperation:operation eventType:@"Watch_All" responseObject:responseObject success:^(id object) {
                success(nil);
            } fail:^(NSString *errorMessage) {
                fail(errorMessage);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Request failed.");
        return;
    }];
}

- (void)leaveConversation:(NSNumber*)conversationId
                  success:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!conversationId || !accessToken) {
        fail(@"Missing conversation or access_token parameters.");
        return;
    }
    // params
    NSDictionary *parameters = @{@"access_token": accessToken};
    NSString *leavePath = [NSString stringWithFormat:@"me/conversations/%@/leave", conversationId];
    //    JNLog(@"leavePath: %@", leavePath);
    [self POST:leavePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        JNLog(@"%@", responseObject);
        if ([operation.request.URL.absoluteString rangeOfString:leavePath].location != NSNotFound) {
            
            [self handleOperation:operation eventType:@"Leave_Conversation" responseObject:responseObject success:^(id object) {
                id meta = [responseObject objectForKey:@"meta"];
                if (meta && [meta respondsToSelector:@selector(objectForKey:)]) {
                    id code = [meta objectForKey:@"code"];
                    if (code && [code isKindOfClass:[NSNumber class]] && [((NSNumber*) code) isEqualToNumber:@(200)]) {
                        success(nil);
                        return;
                    }
                    // TODO: handle 400 could not delete
                }
                fail(@"Problem leaving conversation.");
            } fail:^(NSString *errorMessage) {
                fail(errorMessage);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to leave converstion.");
        return;
    }];
}

//- (void)updateUser:(NSManagedObject*)user
//           success:(SGAPIClientSuccessBlock)success
//              fail:(SGAPIClientFailBlock)fail
//{
//    // access token parameter
//    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
//    //    id deviceToken = [JNSimpleDataStore getValueForKey:SGDeviceTokenKey];
//    //    if (!accessToken || !deviceToken) {
//    if (!accessToken) {
//        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
//        fail(@"Missing update user requirements.");
//        return;
//    }
//    
//    // update user params
//    id name = [user valueForKey:@"name"];
//    id email = [user valueForKey:@"email"];
//    id phone = [user valueForKey:@"phone"];
//    
//    // params
//    NSDictionary *parameters = @{@"access_token": accessToken,
//                                 //                                 @"device_token": deviceToken,
//                                 @"name": name,
//                                 @"email": email,
//                                 @"phone": phone};
//    //    JNLog(@"parameters: %@", parameters);
//    
//    NSString *updateUserPath = @"me";
//    [self POST:updateUserPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //        JNLog(@"%@", responseObject);
//        if ([operation.request.URL.absoluteString rangeOfString:updateUserPath].location != NSNotFound) {
//            
//            [self handleOperation:operation eventType:@"Update_User" responseObject:responseObject success:^(id object) {
//                id data = [object objectForKey:@"data"];
//                if (data && [data isKindOfClass:[NSDictionary class]]) {
//                    success(nil);
//                    return;
//                }
//                // TODO: handle 400: "problem updating"
//                fail(@"Problem updating.");
//            } fail:^(NSString *errorMessage) {
//                fail(errorMessage);
//            }];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
//        fail(@"Failed to update user.");
//        return;
//    }];
//}

- (void)createVideoWithParts:(NSArray*)partFileNames
              conversationId:(NSUInteger)conversationId
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail
{
    [self createVideoWithParts:partFileNames conversationId:conversationId isReply:NO success:success fail:fail];
}

- (void)createVideoWithParts:(NSArray*)partFileNames
              conversationId:(NSUInteger)conversationId
                     isReply:(BOOL)isReply
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
        fail(@"Missing update user requirements.");
        return;
    }
    NSMutableDictionary *parameters = [@{@"access_token": accessToken} mutableCopy];
    
    // part_urls
    if (![NSArray isNotEmptyArray:partFileNames]) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"part filenames missing or empty" error:nil];
        fail(@"Sorry! There was a problem sending the video. Please retry.");
    }
    [parameters setValue:partFileNames forKey:@"part_urls"];
    
    if (isReply) {
        [parameters setValue:@"true" forKey:@"reply"];
    }
    
    NSString *videoWithPartsPath = [NSString stringWithFormat:@"me/conversations/%@/videos/parts", @(conversationId)];
    [self POST:videoWithPartsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleOperation:operation eventType:@"Create_Video_Parts" responseObject:responseObject success:^(id object) {
            NSDictionary *data = [object objectForKey:@"data"];
            success(data);
        } fail:^(NSString *errorMessage) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
            fail(errorMessage);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Sorry! There was a problem sending the video. Please try again.");
    }];
}

- (void)createVideoWithGUID:(NSString*)guid
                      parts:(NSArray*)partFileNames
             conversationId:(NSUInteger)conversationId
                 watchedIds:(NSArray*)watchedIds
                    isReply:(BOOL)isReply
                   subtitle:(NSString*)subtitle
         retryNumberOfTimes:(NSUInteger)retryNumberOfTimes
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail
{
    if (retryNumberOfTimes == 0) {
        return;
    }
    
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
        fail(@"Missing update user requirements.");
        return;
    }
    NSMutableDictionary *parameters = [@{@"access_token": accessToken} mutableCopy];
    
    if ([NSString isNotEmptyString:guid]) {
        [parameters setObject:guid forKey:@"guid"];
    }
    
    // part_urls
    if (![NSArray isNotEmptyArray:partFileNames]) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"part filenames missing or empty" error:nil];
        fail(@"Sorry! There was a problem sending the video. Please retry.");
    }
    [parameters setValue:partFileNames forKey:@"part_urls"];
    
    if (isReply) {
        [parameters setValue:@"true" forKey:@"reply"];
    }
    
    if ([NSString isNotEmptyString:subtitle]) {
        [parameters setValue:subtitle forKey:@"subtitle"];
    }
	
    if ([NSArray isNotEmptyArray:watchedIds]) {
        [parameters setValue:watchedIds forKey:@"watched_ids"];
    }
    
    JNLogObject(parameters);
    
    NSString *videoWithPartsURLString = [NSString stringWithFormat:@"%@/me/conversations/%@/videos/parts", kSGAPIBasePath, @(conversationId)];

    NSError *error;
    NSMutableURLRequest *urlRequest = [self.requestSerializer requestWithMethod:@"POST" URLString:videoWithPartsURLString parameters:parameters error:&error];
    urlRequest.timeoutInterval = kSGVideoPartsSaveTimeout;
    
    @weakify(self);
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        
        [self handleOperation:operation eventType:@"Create_Video_Parts" responseObject:responseObject success:^(id object) {
            NSDictionary *data = [object objectForKey:@"data"];
            success(data);
        } fail:^(NSString *errorMessage) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
            fail(errorMessage);
        }];
        
        [self endBackgroundTask];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self beginBackgroundTask];
        
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        if (error && [error isARequestTimeout]) {
            [SGMetrics addMetric:SGKeenErrorVideoPartsTimeout];
        }
        
        if (fail) {
            fail(@"failed after retries");
        }

        JNLogPrimitive(retryNumberOfTimes);
        [JNAppManager printAppState];
        
        @weakify(self);
        [self performBlock:^{
            
            [self_weak_
             createVideoWithGUID:guid
             parts:partFileNames
             conversationId:conversationId
             watchedIds:watchedIds
             isReply:isReply
             subtitle:subtitle
             retryNumberOfTimes:retryNumberOfTimes - 1
             success:success
             fail:fail];
            
        } afterDelay:kSGVideoPartsRetryDelay];
        
    }];
    [self.operationQueue addOperation:operation];
}

- (void)createVideoWithParts:(NSArray*)partFileNames
                   usernames:(NSArray*)usernames
                     invites:(NSArray*)invites
                        name:(NSString*)name
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
        fail(@"Missing update user requirements.");
        return;
    }
    NSMutableDictionary *parameters = [@{@"access_token": accessToken} mutableCopy];
    
    // part_urls
    if ([NSArray isNotEmptyArray:partFileNames]) {
        [parameters setValue:partFileNames forKey:@"part_urls"];
    } else {
        JNLog(@"no part urls");
    }
    
    if ([NSArray isNotEmptyArray:usernames]) {
        [parameters setValue:usernames forKey:@"username"];
    }
    
    if ([NSArray isNotEmptyArray:invites]) {
        [parameters setValue:invites forKey:@"invites"];
    }
    
    // set name if exists
    if ([NSString isNotEmptyString:name]) {
        [parameters setValue:name forKey:@"name"];
    }
    
    JNLogObject(parameters);
    
    [self POST:@"me/conversations" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleOperation:operation eventType:@"Create_Convo" responseObject:responseObject success:^(id object) {
            NSDictionary *data = [object objectForKey:@"data"];
            success(data);
        } fail:^(NSString *errorMessage) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
            fail(errorMessage);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(NSLocalizedString(@"failed.request.create.conversation", nil));
    }];
}

- (void)createVideoWithParts:(NSArray*)partFileNames
                     invites:(NSArray*)invites
                        name:(NSString*)name
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
        fail(@"Missing update user requirements.");
        return;
    }
    NSMutableDictionary *parameters = [@{@"access_token": accessToken} mutableCopy];
    
    // part_urls
    NSAssert([NSArray isNotEmptyArray:partFileNames], @"part_urls missing");
    if ([NSArray isNotEmptyArray:partFileNames]) {
        [parameters setValue:partFileNames forKey:@"part_urls"];
    }
    
    if ([NSArray isNotEmptyArray:invites]) {
        [parameters setValue:invites forKey:@"invites"];
    }
    
    // set name if exists
    if ([NSString isNotEmptyString:name]) {
        [parameters setValue:name forKey:@"name"];
    }
    
    JNLogObject(parameters);
    
    [self POST:@"me/conversations" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleOperation:operation eventType:@"Create_Convo" responseObject:responseObject success:^(id object) {
            NSDictionary *data = [object objectForKey:@"data"];
            success(data);
        } fail:^(NSString *errorMessage) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:errorMessage error:nil];
            fail(errorMessage);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Sorry! There was a problem creating the conversation. Please try again.");
    }];
}

- (void)getMembersForConversationID:(NSNumber*)conversationID
                            success:(SGAPIClientSuccessBlock)success
                               fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    
    NSString *membersPath = [NSString stringWithFormat:@"me/conversations/%@/members", conversationID];
    
    [self GET:membersPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self handleOperation:operation eventType:@"Members_Check" responseObject:responseObject success:^(id object) {
            id data = [object objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSArray class]]) {
                success(data);
            } else {
                fail(@"No data found.");
            }
        } fail:^(NSString *errorMessage) {
            fail(errorMessage);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to check members.");
    }];
}

- (void)blockUser:(NSNumber*)userID
          success:(SGAPIClientSuccessBlock)success
             fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    NSString *userBlockPath = [NSString stringWithFormat:@"me/users/%@/mute", userID];
    
    [self POST:userBlockPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self handleOperation:operation eventType:@"Block_User" responseObject:responseObject success:^(id object) {
            
            success(nil);
            return;
            
        } fail:^(NSString *errorMessage) {
            fail(errorMessage);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to block user.");
    }];
}

- (void)unblockUser:(NSNumber*)userID
            success:(SGAPIClientSuccessBlock)success
               fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    NSString *userBlockPath = [NSString stringWithFormat:@"me/users/%@/unmute", userID];
    
    [self POST:userBlockPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self handleOperation:operation eventType:@"Unblock_User" responseObject:responseObject success:^(id object) {
            
            success(nil);
            return;
            
        } fail:^(NSString *errorMessage) {
            fail(errorMessage);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to unblock user.");
    }];
}

- (void)goodbyeConversation:(NSUInteger)conversationId
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail
{
    [self goodbyeConversation:conversationId watchedIds:nil success:success fail:fail];
}

- (void)goodbyeConversation:(NSUInteger)conversationId
                 watchedIds:(NSArray*)watchedIds
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail
{
    // access token parameter
    id accessToken = [JNSimpleDataStore getValueForKey:kSGAccessTokenKey];
    if (!accessToken) {
        JNLog(@"ERROR: nil accessaccessToken or deviceToken");
        fail(@"Missing update user requirements.");
        return;
    }
    NSMutableDictionary *parameters = [@{@"access_token": accessToken} mutableCopy];
    
    if(watchedIds) {
        [parameters setValue:watchedIds forKey:@"watched_ids"];
    }
    
    NSString *goodbyeConversationPath = [NSString stringWithFormat:@"me/conversations/%@/goodbye", @(conversationId)];

    
    [self POST:goodbyeConversationPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self handleOperation:operation eventType:@"Goodbye_Conversation" responseObject:responseObject success:^(id object) {
            // success
            success(nil);
        } fail:^(NSString *errorMessage) {
            // fail
            fail(errorMessage);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to unblock user.");
    }];
}

- (void)getUserById:(NSUInteger)conversationId
            success:(SGAPIClientSuccessBlock)success
               fail:(SGAPIClientFailBlock)fail
{
    NSDictionary *parameter = [[self class] createAccessTokenParameter];
    [self GET:@"me" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *data = [(NSDictionary*) responseObject objectForKey:@"data"];
        success(data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(JNLocalizedString(@"failed.request.user.details.alert.body"));
    }];
}

- (void)updateDeviceToken:(NSString*)deviceToken
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameter = [[[self class] createAccessTokenParameter] mutableCopy];
    [parameter setValue:deviceToken forKey:@"device_token"];
    [self POST:@"me" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to update device token.");
    }];
}

#pragma mark - Check contacts

- (void)checkContacts:(NSDictionary*)parameters
              success:(SGAPIClientSuccessBlock)success
                 fail:(SGAPIClientFailBlock)fail
{
    [self POST:@"contacts/check" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            id data = [responseObject objectForKey:@"data"];
            if ([NSDictionary isNotNullDictionary:data]) {
                success(data);
            } else {
                success(responseObject);
            }
        } else {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(JNLocalizedString(@"failed.request.check.contacts.alert.body"));
    }];
}

#pragma mark Video - mark as watched

- (void)markVideoAsWatched:(NSString*)guid
                   success:(SGAPIClientSuccessBlock)success
                      fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    NSString *markVideoAsWatchedPath = [NSString stringWithFormat:@"me/videos/%@/read", guid];
    
    [self POST:markVideoAsWatchedPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleOperation:operation eventType:@"Mark_As_Watched" responseObject:responseObject success:^(id object) {
            success(nil);
        } fail:^(NSString *errorMessage) {
            fail(errorMessage);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to block user.");
    }];
}

#pragma mark - Friends

- (void)getFriendsSuccess:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail
{
    NSDictionary *parameters = [self.class createAccessTokenParameter];
    [self GET:@"me/friends" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            id data = [responseObject objectForKey:@"data"];
            if (success) success(data);
        } else {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to get friends.");
    }];
}

- (void)addFriendsWithUsernames:(NSArray*)usernames
                        success:(SGAPIClientSuccessBlock)success
                           fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    // usernames
    [parameters setObject:usernames forKey:@"username"];
    
    [self POST:@"me/friends/add" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLogObject(responseObject);
        if (success) success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to add friend.");
    }];
}

- (void)removeFriendWithUsername:(NSString*)username
                   success:(SGAPIClientSuccessBlock)success
                      fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    [parameters setObject:username forKey:@"username"];
    
    NSString *path = [NSString stringWithFormat:@"me/friends/remove"];
    [self POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        if (fail) fail(@"Failed to remove friend");
    }];
}

- (void)getUnaddedFriendsSuccess:(SGAPIClientSuccessBlock)success
                            fail:(SGAPIClientFailBlock)fail
{
    NSDictionary *parameters = [self.class createAccessTokenParameter];
    [self GET:@"me/friends/unadded" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id data = nil;
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            data = [responseObject objectForKey:@"data"];
        }
        if (success) success(data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to get unadded friends.");
    }];
}

- (void)searchForUsername:(NSString*)username
                  success:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    [parameters setObject:username forKey:@"username"];
    [self POST:@"me/users/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id data = nil;
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            data = [responseObject objectForKey:@"data"];
        }
        if (success) success(data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        fail(@"Failed to get unadded friends.");
    }];
}

#pragma mark - Invites

- (void)invitedContacts:(NSArray*)invitedContacts
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    [parameters setObject:invitedContacts forKey:@"invites"];
    JNLogObject(parameters);
    [self POST:@"me/invites" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLog(@"success");
        if (success) {
            success(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        if (fail) {
            fail(@"Failed to get unadded friends.");
        }
    }];
}

- (void)invitesConfirm:(NSArray*)contacts
               success:(SGAPIClientSuccessBlock)success
                  fail:(SGAPIClientFailBlock)fail
{
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    [parameters setObject:contacts forKey:@"invites"];
    JNLogObject(parameters);
    [self POST:@"me/invites/confirm" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLog(@"success");
        if (success) {
            success(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        if (fail) {
            fail(@"Failed to send contacts confirm");
        }
    }];
}

#pragma mark - Text

- (void)createText:(NSString*)text
              guid:(NSString*)guid
    conversationID:(NSNumber*)conversationID
retryNumberOfTimes:(NSUInteger)retryNumberOfTimes
           success:(SGAPIClientSuccessBlock)success
              fail:(SGAPIClientFailBlock)fail
{
    if (retryNumberOfTimes == 0) {
        [self endBackgroundTask];
        return;
    }
    
    NSMutableDictionary *parameters = [[self.class createAccessTokenParameter] mutableCopy];
    if ([NSString isNotEmptyString:text]) {
        [parameters setObject:text forKey:@"text"];
    }
    if ([NSString isNotEmptyString:guid]) {
        [parameters setObject:guid forKey:@"guid"];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@me/conversations/%@/text", kSGAPIBasePath, conversationID];
    NSError *error;
    NSMutableURLRequest *urlRequest = [self.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:&error];
    urlRequest.timeoutInterval = kSGTextSaveTimeout;

    AFHTTPRequestOperation *operation = [self
     HTTPRequestOperationWithRequest:urlRequest
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         JNLog(@"success");
         if (success) {
             success(nil);
         }
         
         [self endBackgroundTask];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [self beginBackgroundTask];
         
         [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
         if (fail) {
             fail(@"Failed request");
         }
         
         JNLogPrimitive(retryNumberOfTimes);
         [JNAppManager printAppState];
         
         @weakify(self);
         [self performBlock:^{
             
             [self_weak_
              createText:text
              guid:guid
              conversationID:conversationID
              retryNumberOfTimes:retryNumberOfTimes - 1
              success:success
              fail:fail];
             
         } afterDelay:kSGTextRetryDelay];
     }];
    
    [self.operationQueue addOperation:operation];
}

@end






#pragma mark -

@implementation NSError (SGAddition)

- (BOOL)isARequestTimeout
{
    return [self.localizedDescription rangeOfString:@"The request timed out"].location != NSNotFound;
}

@end
