//
//  SGMessage+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMessage.h"
#import "SGVideo+Service.h"
#import "SGMessageText+Service.h"

#define kSGFetchMessagesByConversationID @"/api/me/conversations/%@/messages"

@interface SGMessage ()

@property (nonatomic, readonly) BOOL isVideoType;
@property (nonatomic, readonly) BOOL isMessageTextType;
@property (nonatomic, readonly) BOOL shouldDisplayOnLeft;
@property (nonatomic, readonly) BOOL shouldDisplayOnRight;

@end

@interface SGMessage (Service)

- (SGMessageText*)getMessageText;
- (SGVideo*)getVideo;

#pragma mark - Init

+ (SGMessage*)initFromJSONDictionary:(NSDictionary*)jsonDictionary
                        didInitVideo:(void(^)(SGVideo *video))didInitVideo
                  didInitMessageText:(void(^)(SGMessageText *messageText))didInitMessageText;

#pragma mark - Fetch

+ (SGMessage*)fetchMessageWithContentGUID:(NSString*)guid;

+ (void)fetchInitialMessagesWithConversationID:(NSNumber*)conversationID
                        didFetchUnreadMessages:(void(^)(NSArray *unreadMessages))didFetchUnreadMessages
                  didFetchRecentlyReadMessages:(void(^)(NSArray *recentlyReadMessages))didFetchRecentlyReadMessages
                                       success:(void(^)(NSArray *initialMessages))success
                                          fail:(void(^)(NSString *errorMessage))fail;

+ (void)fetchAllUnwatchedVideoMessagesCompleted:(void(^)(NSArray *allUnreadMessages))completed
                                           fail:(void(^)(NSString *errorMessage))fail;

+ (NSNumber*)getTotalUnreadCountForConversationID:(NSNumber*)conversationID;

#pragma mark - Fetch Initial Messages

+ (void)fetchUnreadMessagesByConversationID:(NSNumber*)conversationID
                                    success:(void(^)(NSArray *unreadMessages))success
                                       fail:(void(^)(NSString *errorMessage))fail;

+ (void)fetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                       pageNumber:(NSNumber*)pageNumber
                        didFetchLocalReadMessages:(void(^)(NSArray *readMessages))didFetchLocalReadMessages
                                          success:(void(^)(NSArray*))success
                                             fail:(void(^)(NSString*))fail;

+ (void)localFetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                            pageNumber:(NSNumber*)pageNumber
                                               success:(void(^)(NSArray *))success
                                                  fail:(void(^)(NSString *errorMessage))fail;

+ (void)remoteFetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                             pageNumber:(NSNumber*)pageNumber
                                                success:(void(^)(NSArray *recentlyReadMessages))success
                                                   fail:(void(^)(NSString *errorMessage))fail;

#pragma mark - Updates

- (void)markAsReadCompleted:(void(^)())completed failed:(void(^)())failed;

#pragma mark - Mark Video as watched

- (void)markVideoAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed;

#pragma mark - Save

- (void)save;

@end
