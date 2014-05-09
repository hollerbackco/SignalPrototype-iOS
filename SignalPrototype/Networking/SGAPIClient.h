//
//  SGAPIClient.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <AFNetworking.h>

typedef void (^SGAPIClientSuccessBlock)(id object);
typedef void (^SGAPIClientFailBlock)(NSString *errorMessage);

@interface SGAPIClient : AFHTTPRequestOperationManager

#pragma mark - Class methods

+ (SGAPIClient *)sharedClient;

+ (NSDictionary*)createAccessTokenParameter;

#pragma mark - Requests

#pragma mark - Sign up/sign in

- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
            deviceToken:(NSString*)deviceToken
               password:(NSString*)password
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail;

- (void)sendPinWithPhone:(NSString*)phone
                 success:(SGAPIClientSuccessBlock)success
                    fail:(SGAPIClientFailBlock)fail;

- (void)checkEmail:(NSString*)email
           success:(SGAPIClientSuccessBlock)successBlock
              fail:(SGAPIClientFailBlock)failBlock;

// old sign in/sign up
- (void)signInWithEmail:(NSString*)email
               password:(NSString*)password
            deviceToken:(NSString*)deviceToken
                success:(SGAPIClientSuccessBlock)successBlock
                   fail:(SGAPIClientFailBlock)failBlock;

- (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
                   name:(NSString*)name
                  phone:(NSString*)phone
            deviceToken:(NSString*)deviceToken
                 cohort:(NSString*)cohort
                success:(SGAPIClientSuccessBlock)successBlock
                   fail:(SGAPIClientFailBlock)failBlock;
// old sign in/sign up

- (void)logoutWithAccessToken:(NSString*)accessToken
                      success:(SGAPIClientSuccessBlock)successBlock
                         fail:(SGAPIClientFailBlock)failBlock;

- (void)clearUnwatchedVideos:(NSNumber*)conversationId
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail;

- (void)leaveConversation:(NSNumber*)conversationId
                  success:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail;

// TODO: update to use without CoreData
//- (void)updateUser:(NSManagedObject*)user
//           success:(SGAPIClientSuccessBlock)success
//              fail:(SGAPIClientFailBlock)fail;

#pragma mark - Create Video

- (void)createVideoWithParts:(NSArray*)partFileNames
              conversationId:(NSUInteger)conversationId
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail;

- (void)createVideoWithParts:(NSArray*)partFileNames
              conversationId:(NSUInteger)conversationId
                     isReply:(BOOL)isReply
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail;

- (void)createVideoWithGUID:(NSString*)guid
                      parts:(NSArray*)partFileNames
             conversationId:(NSUInteger)conversationId
                 watchedIds:(NSArray*)watchedIds
                    isReply:(BOOL)isReply
                   subtitle:(NSString*)subtitle
         retryNumberOfTimes:(NSUInteger)retryNumberOfTimes
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail;

- (void)createVideoWithParts:(NSArray*)partFileNames
                   usernames:(NSArray*)usernames
                     invites:(NSArray*)invites
                        name:(NSString*)name
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail;

- (void)createVideoWithParts:(NSArray*)partFileNames
                     invites:(NSArray*)invites
                        name:(NSString*)name
                     success:(SGAPIClientSuccessBlock)success
                        fail:(SGAPIClientFailBlock)fail;

#pragma mark - Conversation members

- (void)getMembersForConversationID:(NSNumber*)conversationID
                            success:(SGAPIClientSuccessBlock)success
                               fail:(SGAPIClientFailBlock)fail;

#pragma mark - Block/Unblock users

- (void)blockUser:(NSNumber*)userID
          success:(SGAPIClientSuccessBlock)success
             fail:(SGAPIClientFailBlock)fail;

- (void)unblockUser:(NSNumber*)userID
            success:(SGAPIClientSuccessBlock)success
               fail:(SGAPIClientFailBlock)fail;

#pragma mark - 

- (void)goodbyeConversation:(NSUInteger)conversationId
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail;

- (void)goodbyeConversation:(NSUInteger)conversationId
                 watchedIds:(NSArray*)watchedIds
                    success:(SGAPIClientSuccessBlock)success
                       fail:(SGAPIClientFailBlock)fail;

- (void)getUserById:(NSUInteger)conversationId
            success:(SGAPIClientSuccessBlock)success
               fail:(SGAPIClientFailBlock)fail;

- (void)updateDeviceToken:(NSString*)deviceToken
                  success:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail;

#pragma mark - Check contacts

// NOTE: check/contacts can be called with access_token and will return different results. It is up to the caller to provide the access_token
- (void)checkContacts:(NSDictionary*)parameters
              success:(SGAPIClientSuccessBlock)success
                 fail:(SGAPIClientFailBlock)fail;

#pragma mark Video - mark as watched

- (void)markVideoAsWatched:(NSString*)guid
                   success:(SGAPIClientSuccessBlock)success
                      fail:(SGAPIClientFailBlock)fail;

#pragma mark - Friends

- (void)getFriendsSuccess:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail;

- (void)addFriendsWithUsernames:(NSArray*)usernames
                        success:(SGAPIClientSuccessBlock)success
                           fail:(SGAPIClientFailBlock)fail;

- (void)removeFriendWithUsername:(NSString*)username
                         success:(SGAPIClientSuccessBlock)success
                            fail:(SGAPIClientFailBlock)fail;

- (void)getUnaddedFriendsSuccess:(SGAPIClientSuccessBlock)success
                            fail:(SGAPIClientFailBlock)fail;

- (void)searchForUsername:(NSString*)username
                  success:(SGAPIClientSuccessBlock)success
                     fail:(SGAPIClientFailBlock)fail;

#pragma mark - Invites

- (void)invitedContacts:(NSArray*)invitedContacts
                success:(SGAPIClientSuccessBlock)success
                   fail:(SGAPIClientFailBlock)fail;

- (void)invitesConfirm:(NSArray*)contacts
               success:(SGAPIClientSuccessBlock)success
                  fail:(SGAPIClientFailBlock)fail;

#pragma mark - Text

- (void)createText:(NSString*)text
              guid:(NSString*)guid
    conversationID:(NSNumber*)conversationID
retryNumberOfTimes:(NSUInteger)retryNumberOfTimes
           success:(SGAPIClientSuccessBlock)success
              fail:(SGAPIClientFailBlock)fail;

@end





#pragma mark - NSError (HBAddition)

@interface NSError (HBAddition)

- (BOOL)isARequestTimeout;

@end
