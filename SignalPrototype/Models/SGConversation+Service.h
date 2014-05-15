//
//  SGConversation+Service.h
//  HollerbackApp
//
//  Created by poprot on 10/11/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGConversation.h"

@interface SGConversation (Service)

+ (SGConversation*)initConversationFromJSONDictionary:(NSDictionary*)jsonDictionary;

+ (NSNumber*)generateRandomImageNumber;

+ (SGConversation*)fetchByID:(NSNumber*)conversationID
                     success:(void(^)(SGConversation*))success
                        fail:(void(^)(NSString*))fail;

+ (void)fetchUnwatchedCount:(void (^)( NSNumber *count ) )block;

+ (void)fetchAllConversations:(void(^)(NSArray*))completed;

+ (void)createConversationWithParts:(NSArray*)partFileNames
                          usernames:(NSArray*)usernames
                            invites:(NSArray*)invites
                               name:(NSString*)name
                          completed:(void(^)(SGConversation *conversation))completed
                             failed:(void(^)(NSString *errorMessage))failed;

+ (void)createConversationWithParts:(NSArray*)partFileNames
                            invites:(NSArray*)invites
                               name:(NSString*)name
                          completed:(void(^)(SGConversation *conversation))completed
                             failed:(void(^)(NSString *errorMessage))failed;

+ (void)updateUnreadCount:(NSNumber*)unreadCount
           conversationID:(NSNumber*)conversationID
                completed:(void(^)())completed
                   failed:(void(^)())failed;

#pragma mark - Follow/Unfollow

+ (void)followConversationID:(NSNumber*)conversationID
                   completed:(void(^)())completed
                      failed:(void(^)())failed;

+ (void)unfollowConversationID:(NSNumber*)conversationID
                     completed:(void(^)())completed
                        failed:(void(^)())failed;

#pragma mark -

- (void)save;
- (void)touch;
- (void)ttylWithWatchedVideoIds:(NSArray*)watchedIds;
- (void)markAsWatched;
- (void)setSubtitle:(NSString*)subtitle;

#pragma mark - Mark All Text

- (void)localMarkAllTextAsReadCompleted:(void(^)())completed failed:(void(^)())failed;
- (void)remoteMarkAllTextAsReadCompleted:(void(^)())completed failed:(void(^)())failed;

@property int colorCode;

@end
