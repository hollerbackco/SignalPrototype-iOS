//
//  SGSync.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 24/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGSync.h"
#import "SGAPIClient.h"
#import "SGSession.h"
#import "SGConversation+Service.h"
#import "SGMessage+Service.h"
#import "SGMetrics.h"

#import "SGVideodata.h"

@implementation SGSync

#pragma mark - Singleton

+ (SGSync*)sharedInstance
{
    static SGSync *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Public methods

+ (void)broadcastSync
{
    [self.class broadcastSync:nil];
}

+ (void)broadcastSync:(NSDictionary*)userInfo
{
    JNLog();
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kSGSyncPostNotificationName object:nil userInfo:userInfo];
}

+ (void)processSyncData:(NSArray*)syncs onCompletion:(void (^)(void))completionBlock
{
    JNLog();
    // time the sync process
    __block NSDate *syncLocalStartTime = [NSDate date];
    
    // user info containing changes from sync
    NSDictionary *syncUserInfo =
    @{kSGSyncUserInfoConvosKey: [@[] mutableCopy],
      kSGSyncUserInfoMessagesKey: [@[] mutableCopy]};
    
	for(id sync in syncs) {	// insert the data from each sync into the local DB
        id obj = [SGSync processSyncObject:sync];
        if ([obj isKindOfClass:[SGConversation class]]) {
            [[syncUserInfo objectForKey:kSGSyncUserInfoConvosKey] addObject:obj];
        } else if ([obj isKindOfClass:[SGMessage class]]) {
            [[syncUserInfo objectForKey:kSGSyncUserInfoMessagesKey] addObject:obj];
        }
	}
    // sync local time
    CGFloat syncLocalTime = -syncLocalStartTime.timeIntervalSinceNow;
    JNLog(@"Sync remote time: %f", syncLocalTime);
    [SGMetrics addMetric:SGKeenSyncLocalTime withParameters:@{@"timeInSecs": @(syncLocalTime)}];
    
    // broadcast sync completion
    [SGSync broadcastSync:syncUserInfo];
    
    // completed
    if (completionBlock) completionBlock();
}

+ (id)processSyncObject:(NSDictionary*)syncObject
{
    if(syncObject[@"type"] && [syncObject[@"type"] isEqualToString:@"conversation"]) {
        
        // conversation
        SGConversation *conversation = [SGConversation initConversationFromJSONDictionary:syncObject[@"sync"]];
        conversation.identifier = syncObject[@"sync"][@"id"];
        conversation.backgroundImageNumber = [SGConversation generateRandomImageNumber];
        [conversation save];
        
        return conversation;
        
    } else if(syncObject[@"type"] && [syncObject[@"type"] isEqualToString:@"message"]) {
        
        // video message type
        NSDictionary *messageDict = syncObject[@"sync"];
        SGMessage *message =
        [SGMessage
         initFromJSONDictionary:messageDict
         didInitVideo:^(SGVideo *video) {
             [video save];
         } didInitMessageText:^(SGMessageText *messageText) {
             [messageText save];
         }];
        [message save];
        
        return message;
    } else {
        return nil;
    }
}

- (void)syncBeforeLastMessageCompleted:(void(^)(NSArray *syncData))completed
                                failed:(void(^)())failed
{
    JNLog();
    [self syncBeforeLastMessageAt:[SGSession getSyncLastMessageAt] completed:completed failed:failed];
}

- (void)syncBeforeLastMessageAt:(NSDate*)beforeLastMessageAt
                      completed:(void(^)(NSArray *syncData))completed
                         failed:(void(^)())failed
{
    JNLogObject(beforeLastMessageAt);
    NSMutableDictionary *parameters = [[SGAPIClient createAccessTokenParameter] mutableCopy];
    // before_last_message_at
    if (beforeLastMessageAt) {
        [parameters setObject:beforeLastMessageAt forKey:@"before_last_message_at"];
    }
    // count
    [parameters setObject:@(kSGSyncPaginationCount) forKey:@"count"];
    JNLogObject(parameters);
    // call sync
    [[SGAPIClient sharedClient] GET:@"me/sync" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *syncData;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            syncData = [responseObject objectForKey:@"data"];
            JNLogPrimitive(syncData.count);
            
            [self.class processSyncData:syncData onCompletion:^{
                [self.class broadcastSync];
            }];
        }
        if (completed) completed(syncData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        JNLogObject(error);
        if (failed) failed();
    }];
}

@end
