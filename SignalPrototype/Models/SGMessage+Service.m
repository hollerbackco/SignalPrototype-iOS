//
//  SGMessage+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMessage+Service.h"
#import "SGAPIClient.h"
#import "SGUser+Service.h"

@implementation SGMessage (Service)

#pragma mark - Init

+ (SGMessage*)initFromJSONDictionary:(NSDictionary*)jsonDictionary
                        didInitVideo:(void(^)(SGVideo *video))didInitVideo
                  didInitMessageText:(void(^)(SGMessageText *messageText))didInitMessageText
{
    SGMessage *message = nil;
    NSString *messageType = [jsonDictionary objectForKey:@"type"];
    if ([NSString isNotEmptyString:messageType]) {
        NSString *contentGUID = nil;
        // process for video/text
        if ([messageType isEqualToString:kSGMessageTypeVideo]) {
            // process SGVideo
            NSDictionary *videoDict = [jsonDictionary objectForKey:kSGMessageTypeVideo];
//                JNLogObject(videoDict);
            SGVideo *video = (SGVideo*) [SGVideo initFromJSONDictionary:videoDict];
            if (didInitVideo) {
                didInitVideo(video);
            }
//                SGVideo *v = [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchFirstResultWithStatement:@"SELECT * FROM videos WHERE guid = ?", video.guid, nil];
//                JNLogObject(v);
            contentGUID = [videoDict objectForKey:@"guid"];
            
        } else if ([messageType isEqualToString:kSGMessageTypeText]) {
            // process SGText
            NSDictionary *messageTextDict = [jsonDictionary objectForKey:kSGMessageTypeText];
//                JNLogObject(messageTextDict);
            SGMessageText *messageText = (SGMessageText*) [SGMessageText initFromJSONDictionary:messageTextDict];
            if (didInitMessageText) {
                didInitMessageText(messageText);
            }
//                SGMessageText *m = [SGMessageText fetchMessageTextWithGUID:messageText.guid];
//                JNLogObject(m);
            contentGUID = [messageTextDict objectForKey:@"guid"];
        }
        
        // process SGMessage
        NSMutableDictionary *mutableJSONDictionary = [jsonDictionary mutableCopy];
        [mutableJSONDictionary removeObjectForKey:@"video"];
        [mutableJSONDictionary removeObjectForKey:@"text"];
        message = (SGMessage*) [SGMessage initFromJSONDictionary:mutableJSONDictionary];
        message.contentGUID = contentGUID;
        
        return message;
        
    } else {
        return nil;
    }
}

#pragma mark - Properties

- (BOOL)isVideoType
{
    return [self.messageType isEqualToString:kSGMessageTypeVideo];
}

- (BOOL)isMessageTextType
{
    return [self.messageType isEqualToString:kSGMessageTypeText];
}

- (SGMessageText*)getMessageText
{
    if (self.contentGUID) {
        if (!self.messageText) {
            self.messageText = [SGMessageText fetchMessageTextWithGUID:self.contentGUID];
        }
    }
    return self.messageText;
}

- (SGVideo*)getVideo
{
    if (self.contentGUID) {
        if (!self.video) {
            self.video = [SGVideo fetchVideoWithGUID:self.contentGUID];
        }
    }
    return self.video;
}

- (BOOL)shouldDisplayOnLeft
{
    return ![self isSenderTheCurrentUser];
}

- (BOOL)shouldDisplayOnRight
{
    return [self isSenderTheCurrentUser];
}

- (BOOL)isSenderTheCurrentUser
{
    NSNumber *currentUserId = [SGUser getCurrentUserId];
    if (!self.senderID) {
        JNLogObject(self);
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"nil sender id" error:nil];
#warning Todo: investigate bug where this could be nil
        return NO;
    } else if (!currentUserId) {
        JNLogObject([SGUser getCurrentUser]);
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"nil current user id" error:nil];
#warning Todo: investigate bug where this could be nil
        return NO;
    }
    return [self.senderID isEqualToNumber:currentUserId];
}

#pragma mark - Fetch

+ (SGMessage*)fetchMessageWithContentGUID:(NSString*)guid
{
    id messageResult = [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchFirstResultWithStatement:
                        @"SELECT * FROM messages "
                        "WHERE content_guid = ?",
                        guid, nil];
    
    SGMessage *message = (SGMessage*) [SGMessage initFromJSONDictionary:messageResult];
    return message;
}

+ (void)fetchAllUnwatchedVideoMessagesCompleted:(void(^)(NSArray *allUnreadMessages))completed
                                           fail:(void(^)(NSString *errorMessage))fail
{
    JNLog();
    NSString *statement =
    @"SELECT * FROM messages "
    "WHERE type = 'video' "
    "AND is_read = 0";
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        // get # of videos for conversation
        FMResultSet *rs = [db executeQuery:statement];
        NSMutableArray *allUnreadMessages = [NSMutableArray arrayWithCapacity:1];
        while ([rs next]) {
            SGMessage *message = (SGMessage*) [SGMessage initFromJSONDictionary:rs.resultDictionary];
            [allUnreadMessages addObject:message];
        }
        if (completed) {
            completed(allUnreadMessages);
        }
        [rs close];
    }];
    // TODO: fail()
}

+ (NSNumber*)getTotalUnreadCountForConversationID:(NSNumber*)conversationID
{
    JNLogObject(conversationID);
    __block NSNumber *totalUnwatchedCount;
    [self.class fetchUnreadMessagesByConversationID:conversationID success:^(NSArray *unreadMessages) {
        totalUnwatchedCount = @(unreadMessages.count);
    } fail:^(NSString *errorMessage) {
        JNLogObject(errorMessage);
    }];
    return totalUnwatchedCount;
}

#pragma mark - Fetch Initial Messages

+ (void)fetchInitialMessagesWithConversationID:(NSNumber*)conversationID
                        didFetchUnreadMessages:(void(^)(NSArray *unreadMessages))didFetchUnreadMessages
                  didFetchRecentlyReadMessages:(void(^)(NSArray *recentlyReadMessages))didFetchRecentlyReadMessages
                                       success:(void(^)(NSArray *initialMessages))success
                                          fail:(void(^)(NSString *errorMessage))fail
{
    JNLog();
    __block NSMutableArray *initialMessages = [NSMutableArray arrayWithCapacity:1];
    // fetch unread messages
    [self.class fetchUnreadMessagesByConversationID:conversationID success:^(NSArray *unreadMessages) {
        if ([NSArray isNotEmptyArray:unreadMessages]) {
            JNLogObject(@(unreadMessages.count));
            [initialMessages addObjectsFromArray:unreadMessages];
            // call block
            if (didFetchUnreadMessages) {
                didFetchUnreadMessages(unreadMessages);
            }
        }
        // fetch recently read messages
        [self.class
         fetchRecentlyReadMessagesByConversationID:conversationID
         pageNumber:@(1)
         didFetchLocalReadMessages:^(NSArray *readMessages) {
             if (didFetchRecentlyReadMessages) {
                 didFetchRecentlyReadMessages(readMessages);
             }
         } success:^(NSArray *recentlyReadMessages) {
             // merge unread and read messages
             if (recentlyReadMessages) {
                 JNLogObject(@(recentlyReadMessages.count));
                 [initialMessages addObjectsFromArray:recentlyReadMessages];
             }
             JNLogObject(@(initialMessages.count));
             if (success) {
                 success(initialMessages);
             }
         } fail:^(NSString *errorMessage) {
             JNLogObject(errorMessage);
             if (fail) {
                 fail(errorMessage);
             }
         }];
    } fail:^(NSString *errorMessage) {
        JNLogObject(errorMessage);
        if (fail) {
            fail(errorMessage);
        }
    }];
}

+ (void)fetchUnreadMessagesByConversationID:(NSNumber*)conversationID
                                    success:(void(^)(NSArray *unreadMessages))success
                                       fail:(void(^)(NSString *errorMessage))fail
{
    NSString *statement =
    @"SELECT * FROM messages "
    "WHERE conversation_id = ? "
    "AND is_read = 0 "
    "ORDER BY created_at ASC";
    NSArray *allResults =
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     fetchAllResultsWithStatement:statement, conversationID, nil];
    // parse into SGMessage
    NSMutableArray *unreadMessages = [NSMutableArray arrayWithCapacity:0];
    [allResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGMessage *message = (SGMessage*) [SGMessage initFromJSONDictionary:obj];
        [unreadMessages addObject:message];
    }];
    if (success) {
        success(unreadMessages);
    }
}

+ (void)fetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                       pageNumber:(NSNumber*)pageNumber
                        didFetchLocalReadMessages:(void(^)(NSArray *readMessages))didFetchLocalReadMessages
                                          success:(void(^)(NSArray*))success
                                             fail:(void(^)(NSString*))fail
{
    [self
     localFetchRecentlyReadMessagesByConversationID:conversationID
     pageNumber:pageNumber
     success:^(NSArray *localRecentlyReadMessages) {
         JNLogObject(@(localRecentlyReadMessages.count));
         if ([NSArray isNotEmptyArray:localRecentlyReadMessages] &&
             localRecentlyReadMessages.count == kSGNumberOfRecentlyReadMessages) {
             // have fetched enough local messages to complete
             if (success) {
                 success(localRecentlyReadMessages);
             }
         } else if ([NSArray isNotEmptyArray:localRecentlyReadMessages] &&
                    localRecentlyReadMessages.count >= kSGNumberOfRecentlyReadMessages) {
             // fetched more than needed local messages, so this is complete
             if (success) {
                 success([localRecentlyReadMessages subarrayWithRange:NSMakeRange(0, kSGNumberOfRecentlyReadMessages)]);
             }
         } else {
             // fetched less than required local messages, run callback then continue with remote fetch
             if ([NSArray isNotEmptyArray:localRecentlyReadMessages] &&
                 localRecentlyReadMessages.count < kSGNumberOfRecentlyReadMessages) {
                 if (didFetchLocalReadMessages) {
                     didFetchLocalReadMessages(localRecentlyReadMessages);
                 }
             }
             // remote fetch remaining watched messages
             [self
              remoteFetchRecentlyReadMessagesByConversationID:conversationID
              pageNumber:pageNumber
              success:^(NSArray *recentlyReadMessages) {
                  JNLogObject(@(recentlyReadMessages.count));
                  if ([NSArray isNotEmptyArray:recentlyReadMessages]) {
                      //
                      if ([NSArray isNotEmptyArray:localRecentlyReadMessages]) {
                          NSMutableArray *recentlyReadMessages = [NSMutableArray arrayWithCapacity:kSGNumberOfRecentlyReadMessages];
                          [recentlyReadMessages addObjectsFromArray:localRecentlyReadMessages];
                          NSUInteger numOfRecentlyReadMessagesToMerge = MIN(kSGNumberOfRecentlyReadMessages - localRecentlyReadMessages.count, recentlyReadMessages.count - 1);
                          JNLogObject(@(numOfRecentlyReadMessagesToMerge));
                          // only add remote messages if guids don't match
                          [recentlyReadMessages enumerateObjectsUsingBlock:^(SGMessage *messageFromRemote, NSUInteger idx, BOOL *stop) {
                              NSArray *filtered = [recentlyReadMessages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contentGUID == %@", messageFromRemote.contentGUID]];
                              if ([NSArray isEmptyArray:filtered]) {
                                  [recentlyReadMessages addObject:messageFromRemote];
                              }
                          }];
                          // finished
                          if (success) {
                              success(recentlyReadMessages);
                          }
                      } else {
                          if (success) {
                              success(recentlyReadMessages);
                          }
                      }
                  } else {
                      if (success) {
                          success(localRecentlyReadMessages);
                      }
                  }
              } fail:^(NSString *errorMessage) {
                  if (fail) {
                      fail(errorMessage);
                  }
              }];
         }
     } fail:^(NSString *errorMessage) {
         if (fail) {
             fail(errorMessage);
         }
     }];
}

+ (void)localFetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                            pageNumber:(NSNumber*)pageNumber
                                               success:(void(^)(NSArray *))success
                                                  fail:(void(^)(NSString *errorMessage))fail
{
    NSString *statement =
    [NSString stringWithFormat:
     @"SELECT * FROM messages "
     "WHERE conversation_id = ? "
     "AND is_read = 1 "
     "ORDER BY sent_at DESC "
     "LIMIT %@ "
     "OFFSET %@",
     @(kSGNumberOfRecentlyReadMessages),
     @((pageNumber.intValue - 1) * kSGNumberOfRecentlyReadMessages)];
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        // get messages for conversation
        FMResultSet *rs = [db executeQuery:statement, conversationID];
        NSMutableArray *recentlyReadMessages = [NSMutableArray arrayWithCapacity:kSGNumberOfRecentlyReadMessages];
        while ([rs next]) {
//            SGVideo *video = [SGVideo initVideoFromJSONDictionary:rs.resultDictionary];
            SGMessage *message = (SGMessage*) [SGMessage initFromJSONDictionary:rs.resultDictionary];
            message.isRead = rs.resultDictionary[@"is_read"];
            if (message) {
                [recentlyReadMessages addObject:message];
            }
        }
        if (success) {
            success(recentlyReadMessages);
        }
        [rs close];
    }];
}

+ (void)remoteFetchRecentlyReadMessagesByConversationID:(NSNumber*)conversationID
                                             pageNumber:(NSNumber*)pageNumber
                                                success:(void(^)(NSArray *recentlyReadMessages))success
                                                   fail:(void(^)(NSString *errorMessage))fail
{
    NSString *path = [NSString stringWithFormat:kSGFetchMessagesByConversationID, conversationID];
    NSMutableDictionary *parameters = [[SGAPIClient createAccessTokenParameter] mutableCopy];
    [parameters setValue:pageNumber forKey:@"page"];
    [parameters setValue:@(kSGNumberOfRecentlyReadMessages) forKey:@"perPage"];
    [[SGAPIClient sharedClient] GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data;
        NSDictionary *responseJSON = (NSDictionary*) responseObject;
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
            data = [responseObject valueForKeyPath:@"data"];
        }
        if (data && [data isKindOfClass:NSArray.class]) {
            NSMutableArray *recentlyReadMessages = [NSMutableArray arrayWithCapacity:1];
            if ([NSArray isNotEmptyArray:data]) {
                for (id jsonDictionary in data) {
                    if ([jsonDictionary isKindOfClass:[NSDictionary class]]) {
                        // create message from db results
                        SGMessage *message =
                        [SGMessage
                         initFromJSONDictionary:jsonDictionary didInitVideo:^(SGVideo *video) {
                             [video save];
                         } didInitMessageText:^(SGMessageText *messageText) {
                             [messageText save];
                         }];
                        [message save];
                        [recentlyReadMessages addObject:message];
                    }
                }
            }
            if (success) {
                success(recentlyReadMessages);
            }
        } else {
            if (fail) {
                fail(@"parse error");
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"request error" error:error];
        if (fail) {
            fail(JNLocalizedString(@"failed.request.recently.read.messages.alert.body"));
        }
    }];
}

#pragma mark - Updates

- (void)markAsReadCompleted:(void(^)())completed failed:(void(^)())failed
{
    if (!self.isRead.boolValue) {
        self.isRead = @(YES);
        [SGDatabase
         DBQueue:[SGDatabase getDBQueue]
         updateWithStatement:
         @"UPDATE messages "
         "SET is_read = 1 "
         "WHERE content_guid = ?"
         arguments:@[self.contentGUID]];
    }
    if (completed) {
        completed();
    }
}

#pragma mark - Mark Video as watched

- (void)markVideoAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed
{
    JNLog();
    SGVideo *video = [self getVideo];
    video.conversationID = self.conversationID;
    if (video) {
        [video localMarkAsWatchedCompleted:^{
            if (completed) {
                completed();
            }
            // perform remote save
            [video remoteMarkAsWatchedCompleted:^{
                JNLog(@"remote video mark as watched completed");
            } failed:^{
                JNLog(@"remote video mark as watched failed");
                [self localMarkMessageAsUnreadCompleted:^{
                    JNLog("completd localMarkMessageAsUnreadCompleted");
                }];
            }];
        } failed:^{
            if (failed) {
                failed();
            }
        }];
    }
}

- (void)localMarkMessageAsUnreadCompleted:(void(^)())completed
{
    NSString *statement = @"UPDATE messages SET is_read = 0 WHERE content_guid = ?";
    
    [SGDatabase DBQueue:[SGDatabase getDBQueue] updateWithStatement:statement arguments:@[self.contentGUID]];
    
    if (completed) completed();
}

#pragma mark - Save

- (void)save
{
    JNAssert(self.contentGUID);
    JNAssert(self.conversationID);
    JNAssert(self.messageType);
    JNAssert(self.sentAt);
    JNAssert(self.isRead);
    
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"INSERT OR REPLACE INTO messages ("
     "content_guid,"
     "conversation_id, "
     "type,"
     "sent_at,"
     "sender_id,"
     "sender_name,"
     "is_read"
     ") "
     "VALUES (?,?,?,?,?,?,?)"
     arguments:
     @[self.contentGUID,
       self.conversationID,
       self.messageType,
       @(self.sentAt.timeIntervalSince1970),
       self.senderID,
       self.senderName,
       self.isRead]];
}

@end
