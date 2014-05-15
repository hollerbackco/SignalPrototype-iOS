//
//  SGConversation+Service.m
//  HollerbackApp
//
//  Created by poprot on 10/11/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGDatabase.h"

#import "SGConversation+Service.h"
#import "SGVideodata.h"
#import "SGVideo.h"
#import "SGVideo+Service.h"
#import "SGAPIClient.h"
#import "SGMessage+Service.h"
#import "SGSync.h"

#define kSGConversationWatchAll @"/api/me/conversations/%@/watch_all"

@implementation SGConversation (Service)

+ (SGConversation*)initConversationFromJSONDictionary:(NSDictionary*)jsonDictionary
{
    NSError *error;
    SGConversation *conversation = [MTLJSONAdapter modelOfClass:SGConversation.class fromJSONDictionary:jsonDictionary error:&error];
    if (!conversation) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"error processing video" error:error];
    }
    return conversation;
}

+ (NSNumber*)generateRandomImageNumber
{
    int rand = (arc4random() + 1) % 32;
    return @(rand);
}

+ (NSString*)generateRandomBackgroundImageURL
{
    return [NSString stringWithFormat:@"https://s3.amazonaws.com/hb-media/bg-images/%@.png",
            [SGConversation generateRandomImageNumber]];
}

+ (void)fetchUnwatchedCount:(void (^)( NSNumber *count) )block
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [FMResultSet alloc];
        rs = [db executeQuery:@"SELECT COUNT(*) FROM conversations where unread_count > 0"];
        if([rs next])
        {
            NSNumber *count = [rs resultDictionary][@"COUNT(*)"];
            JNLog(@"COUNT :: %d", [count intValue]);
            block(count);
        }
        [rs close];
    }];
}

+ (SGConversation*)fetchByID:(NSNumber*)conversationID
                     success:(void(^)(SGConversation*))success
                        fail:(void(^)(NSString*))fail
{
    JNLog();
    __block SGConversation *conversation;
    
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [FMResultSet alloc];
        rs = [db executeQuery:@"SELECT * FROM conversations WHERE conversation_id = ? LIMIT 1", conversationID];
        if([rs next]) {
            conversation = [SGConversation initConversationFromJSONDictionary:rs.resultDictionary];
        }
        [rs close];
    }];
    if(conversation){
        !success ?: success(conversation);
    }
    return conversation;
}

+ (void)fetchAllConversations:(void(^)(NSArray*))completed
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [FMResultSet alloc];
        rs = [db executeQuery:@"SELECT * FROM conversations WHERE is_deleted = 0 ORDER BY last_message_at DESC"];
        NSMutableArray *conversations = [@[] mutableCopy];
        while (rs.next) {
            SGConversation *conversation = [SGConversation initConversationFromJSONDictionary:rs.resultDictionary];
            [conversations addObject:conversation];
        }
        [rs close];
        JNLogPrimitive(conversations.count);
        completed(conversations);
    }];
}

+ (void)createConversationWithParts:(NSArray*)partFileNames
                          usernames:(NSArray*)usernames
                            invites:(NSArray*)invites
                               name:(NSString*)name
                          completed:(void(^)(SGConversation *conversation))completed
                             failed:(void(^)(NSString *errorMessage))failed
{
    // ensure part_urls are alphabetically sorted
    partFileNames = [partFileNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NSString*) obj1) compare:(NSString*) obj2];
    }];
    JNLogObject(partFileNames);
    [[SGAPIClient sharedClient] createVideoWithParts:partFileNames
                                           usernames:usernames
                                             invites:invites
                                                name:name
                                             success:^(id object) {
                                                 SGConversation *conversation = (SGConversation*) [self initFromJSONDictionary:object];
                                                 conversation.colorCode = @(1);
                                                 conversation.identifier = object[@"id"];
                                                 if (!conversation.lastMessageAt) {
                                                     conversation.lastMessageAt = [NSDate date];
                                                 }
                                                 conversation.backgroundImageNumber = [SGConversation generateRandomImageNumber];
                                                 [conversation save];
                                                 if (completed) completed(conversation);
                                             }
                                                fail:^(NSString *errorMessage) {
                                                    if (failed) failed(errorMessage);
                                                }];
}

+ (void)createConversationWithParts:(NSArray*)partFileNames
                            invites:(NSArray*)invites
                               name:(NSString*)name
                          completed:(void(^)(SGConversation *conversation))completed
                             failed:(void(^)(NSString *errorMessage))failed
{
    // ensure part_urls are alphabetically sorted
    partFileNames = [partFileNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NSString*) obj1) compare:(NSString*) obj2];
    }];
    JNLogObject(partFileNames);

    [[SGAPIClient sharedClient] createVideoWithParts:partFileNames
                                             invites:invites
                                                name:name
                                             success:^(id object) {
                                                 SGConversation *conversation = (SGConversation*) [self initFromJSONDictionary:object];
                                                 conversation.colorCode = @(1);
                                                 conversation.identifier = object[@"id"];
                                                 conversation.lastMessageAt = [NSDate date];
                                                 conversation.backgroundImageNumber = [SGConversation generateRandomImageNumber];
                                                 [conversation save];
                                                 if (completed) completed(conversation);
                                             }
                                                fail:^(NSString *errorMessage) {
                                                    JNLogObject(errorMessage);
                                                    if (failed) failed(errorMessage);
                                                }];
}

+ (void)updateUnreadCount:(NSNumber*)unreadCount
           conversationID:(NSNumber*)conversationID
                completed:(void(^)())completed
                   failed:(void(^)())failed
{
    JNLog(@"unreadCount: %@, conversationID: %@", unreadCount, conversationID);
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"UPDATE conversations "
             "SET unread_count = ? "
             "WHERE conversation_id = ?",
             unreadCount,
             conversationID]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
	}];
    if (completed) {
        completed();
    }
}

#pragma mark - Follow/Unfollow

+ (void)followConversationID:(NSNumber*)conversationID
                   completed:(void(^)())completed
                      failed:(void(^)())failed
{
    [self
     remoteFollowing:YES
     conversationID:conversationID
     completed:^{
         [self localUpdateFollowing:YES conversationID:conversationID completed:^{
             if (completed) {
                 completed();
             }
         } failed:^{
             if (failed) {
                 failed();
             }
         }];
     }
     failed:^{
         if (failed) {
             failed();
         }
     }];
}

+ (void)remoteFollowing:(BOOL)following
         conversationID:(NSNumber*)conversationID
              completed:(void(^)())completed
                 failed:(void(^)())failed
{
    NSDictionary *parameters = [SGAPIClient createAccessTokenParameter];
    
    NSString *path;
    if (following) {
        path = [NSString stringWithFormat:@"me/conversations/%@/follow", conversationID];
    } else {
        path = [NSString stringWithFormat:@"me/conversations/%@/unfollow", conversationID];
    }
    
    [[SGAPIClient sharedClient]
     POST:path
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if (completed) {
             completed();
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
         if (failed) {
             failed();
         }
     }];
}

+ (void)localUpdateFollowing:(BOOL)following
              conversationID:(NSNumber*)conversationID
                   completed:(void(^)())completed
                      failed:(void(^)())failed
{
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"UPDATE conversations SET following = ?"
     arguments:@[@(following)]
     completed:^(NSError *error) {
         if (completed) {
             completed();
         }
     }];
}

+ (void)unfollowConversationID:(NSNumber*)conversationID
                     completed:(void(^)())completed
                        failed:(void(^)())failed
{
    [self
     remoteFollowing:NO
     conversationID:conversationID
     completed:^{
         
         [self localUpdateFollowing:NO conversationID:conversationID completed:^{
             if (completed) {
                 completed();
             }
         } failed:^{
             if (failed) {
                 failed();
             }
         }];
     }
     failed:^{
         if (failed) {
             failed();
         }
     }];
}

#pragma mark -

- (void)save
{
    // Save info locally
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO conversations ("
             @"conversation_id, "
             @"last_message_at, "
             @"name, "
             @"most_recent_thumb_url, "
             @"most_recent_subtitle, "
             @"unread_count, "
             @"is_deleted, "
             @"color_code, "
             @"background_image_number,"
             @"sender_name,"
             @"following) "
             @"VALUES (?,?,?,?,?,?,?,?,?,?,?)",
             self.identifier,
             [[NSDate dateFormatter] stringFromDate:self.lastMessageAt],
             self.name,
             self.mostRecentThumbURL,
             self.mostRecentSubtitle,
             self.unreadCount,
             self.isDeleted,
             self.colorCode,
             self.backgroundImageNumber,
             self.senderName,
             self.following]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        
        [db commit];
    }];
}

- (void)touch
{
    __block NSString *now = [[NSDate dateFormatter] stringFromDate:[NSDate date]];
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
		if(![db executeUpdate:
			 @"UPDATE conversations SET last_message_at = ? WHERE conversation_id = ?",
			 now,
			 self.identifier]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
    
        [db commit];
		JNLog(@"TOUCHED CONVERSATION");
	}];
    
    // broadcast sync completion
    [SGSync broadcastSync];
}

- (void)ttylWithWatchedVideoIds:(NSArray*)watchedIds
{
    JNLog();
    [[SGAPIClient sharedClient] goodbyeConversation:self.identifier.integerValue watchedIds:watchedIds success:^(id object) {
        // Save info locally
        [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
            [db beginTransaction];
            if(![db executeUpdate:
                 @"UPDATE conversations SET most_recent_subtitle = NULL WHERE conversation_id = ?",
                 self.identifier]) {
                [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
            }
            
            [db commit];
            JNLog(@"MARKED CONVERSATION AS ttyl");
        }];
        
        // broadcast sync completion
        [SGSync broadcastSync];

    } fail:^(NSString *errorMessage) {
        // TODO:
    }];
}


- (void)setSubtitle:(NSString*)subtitle
{
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"UPDATE conversations SET most_recent_subtitle = ? WHERE conversation_id = ?",
             subtitle,
             self.identifier]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        
        [db commit];
		JNLog(@"ADD subtitle to CONVERSATION");
	}];
    
    // broadcast sync completion
    [SGSync broadcastSync];
}

- (void)markAsWatched
{
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        JNLog(@"set unread_count to 0");
        if(![db executeUpdate:
             @"UPDATE conversations SET unread_count = ? WHERE conversation_id = ?",
             [NSNumber numberWithInteger:0],
             self.identifier]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        
        [db commit];
		JNLog(@"MARKED CONVERSATION AS WATCHED");
	}];
    
    // broadcast sync completion
    [SGSync broadcastSync];
}

#pragma mark - Mark All Text

- (void)localMarkAllTextAsReadCompleted:(void(^)())completed failed:(void(^)())failed
{
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"UPDATE messages "
     "SET is_read = 1 "
     "WHERE conversation_id = ? "
     "AND type = ?"
     arguments:@[self.identifier, kSGMessageTypeText]
     completed:^(NSError *error) {
         ;
     }];
}

- (void)remoteMarkAllTextAsReadCompleted:(void(^)())completed failed:(void(^)())failed
{
    NSMutableDictionary *parameters = [[SGAPIClient createAccessTokenParameter] mutableCopy];
    [parameters setObject:@[@"text"] forKey:@"message_types"];
    NSString *path = [NSString stringWithFormat:kSGConversationWatchAll, self.identifier];
    [[SGAPIClient sharedClient]
     POST:path
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         JNLog(@"success");
    }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         JNLogObject(error);
    }];
}

@end
