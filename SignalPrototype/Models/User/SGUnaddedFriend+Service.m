//
//  SGUnaddedFriend+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGUnaddedFriend+Service.h"
#import "SGAPIClient.h"

@implementation SGUnaddedFriend (Service)

+ (BOOL)friendDoesExist:(NSString*)username
{
    __block BOOL friendDoesExist = NO;
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM unadded_friends WHERE username = ?", username];
        SGUnaddedFriend *friend;
        if (rs.next) {
            friend = (SGUnaddedFriend*) [SGUnaddedFriend initFromJSONDictionary:rs.resultDictionary];
            friendDoesExist = YES;
        }
        [rs close];
    }];
    return friendDoesExist;
}

+ (void)syncUnaddedFriendsWithNewFlag:(BOOL)isNew
                            completed:(void(^)(NSArray *unaddedFriends))completed
                               failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient] getUnaddedFriendsSuccess:^(id data) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:1];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SGUnaddedFriend *friend = (SGUnaddedFriend*) [SGUnaddedFriend initFromJSONDictionary:obj];
                if (![self.class friendDoesExist:friend.username]) {
                    friend.isNew = @(isNew);
                    [friend save];
                }
                [list addObject:friend];
            }];
            if (completed) completed(list);
        } else {
            if (completed) completed(nil);
        }
    } fail:^(NSString *errorMessage) {
        if (failed) failed(errorMessage);
    }];
}

+ (void)fetchUnaddedFriendsCompleted:(void (^)(NSArray *unaddedFriends))completed
                              failed:(void (^)(NSString *errorMessage))failed
{
    __block NSMutableArray *unaddedFriends = [NSMutableArray arrayWithCapacity:1];
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM unadded_friends ORDER BY username"];
        SGUnaddedFriend *friend;
        while (rs.next) {
            friend = (SGUnaddedFriend*) [SGUnaddedFriend initFromJSONDictionary:rs.resultDictionary];
            [unaddedFriends addObject:friend];
        }
        [rs close];
    }];
    if (completed) completed(unaddedFriends);
}

+ (BOOL)hasNewUnaddedFriends
{
    __block BOOL hasNewUnaddedFriends = NO;
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM unadded_friends WHERE is_new = 1"];
        if (rs.next) {
            hasNewUnaddedFriends = YES;
        }
        [rs close];
    }];
    JNLogPrimitive(hasNewUnaddedFriends);
    return hasNewUnaddedFriends;
}

+ (void)clearNewUnaddedFriendsCompleted:(void (^)())completed
                                 failed:(void (^)(NSString *errorMessage))failed
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [db executeUpdate:@"UPDATE unadded_friends SET is_new = 0"];
        [db commit];
    }];
    if (completed) completed();
}

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO unadded_friends ("
             @"id, "
             @"name, "
             @"username, "
             @"is_new)"
             @"VALUES (?,?,?,?)",
             self.identifier,
             self.name,
             self.username,
             self.isNew]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

@end
