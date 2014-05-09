//
//  SGFriend+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 20/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGFriend+Service.h"
#import "SGAPIClient.h"

@implementation SGFriend (Service)

+ (void)addFriendsWithUsernames:(NSArray*)usernames
                      completed:(void(^)())completed
                         failed:(void(^)())failed
{
    [[SGAPIClient sharedClient] addFriendsWithUsernames:usernames success:^(id object) {
        if (completed) completed();
    } fail:^(NSString *errorMessage) {
        if (failed) failed();
    }];
}

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO friends ("
             @"id, "
             @"name, "
             @"username)"
             @"VALUES (?,?,?)",
             self.identifier,
             self.name,
             self.username]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

- (void)remove
{
    // local
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if (![db executeQuery:@"DELETE FROM friends WHERE username = ?", self.username]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
    // remote
    [[SGAPIClient sharedClient] removeFriendWithUsername:self.username success:^(id object) {
        JNLog(@"remove completed");
    } fail:^(NSString *errorMessage) {
        JNLog(@"remove failed: %@", errorMessage);
    }];
}

@end
