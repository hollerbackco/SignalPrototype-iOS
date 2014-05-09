//
//  SGUser+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGUser+Service.h"
#import "JNSimpleDataStore.h"
#import "SGAPIClient.h"
#import "SGFriend+Service.h"
#import "SGRecentFriend+Service.h"
#import "SGContact+Service.h"

@implementation SGUser (Service)

+ (BOOL)isLoggedIn
{
    JNLog();
    JNLogPrimitive([JNSimpleDataStore getValueForKey:kSGAccessTokenKey] != nil);
    return [JNSimpleDataStore getValueForKey:kSGAccessTokenKey] != nil;
}

static SGUser *_currentUser;

+ (void)saveCurrentUser:(SGUser*)currentUser
{
    [JNSimpleDataStore archiveObject:currentUser filename:kSGCurrentUser];
    _currentUser = currentUser;
}

+ (SGUser*)getCurrentUser
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentUser = (SGUser*) [JNSimpleDataStore unarchiveObjectWithFilename:kSGCurrentUser];
    });
    return _currentUser;
}

+ (NSNumber*)getCurrentUserId
{
    SGUser *currentUser = [self.class getCurrentUser];
    if (currentUser) {
        NSNumber *currentUserId = currentUser.identifier;
        if ([NSNumber isNotNullNumber:currentUserId]) {
            return currentUserId;
        } else {
            currentUserId = (NSNumber*) [JNSimpleDataStore getValueForKey:kSGUserIdKey];
            if ([NSNumber isNotNullNumber:currentUserId]) {
                currentUser.identifier = currentUserId;
                [self.class saveCurrentUser:currentUser];
                return currentUserId;
            } else {
                return nil;
            }
        }
    } else {
        NSNumber *currentUserId = (NSNumber*) [JNSimpleDataStore getValueForKey:kSGUserIdKey];
        if ([NSNumber isNotNullNumber:currentUserId]) {
            currentUser = [SGUser new];
            currentUser.identifier = currentUserId;
            [self.class saveCurrentUser:currentUser];
            return currentUserId;
        } else {
            return nil;
        }
    }
}

+ (NSString*)getCurrentUsername
{
    SGUser *currentUser = [self.class getCurrentUser];
    if (currentUser) {
        NSString *currentUsername = currentUser.username;
        if ([NSString isNotEmptyString:currentUsername]) {
            return currentUsername;
        } else {
            currentUsername = (NSString*) [JNSimpleDataStore getValueForKey:kSGUsernameKey];
            if ([NSString isNotEmptyString:currentUsername]) {
                currentUser.username = currentUsername;
                [self.class saveCurrentUser:currentUser];
                return currentUsername;
            } else {
                return nil;
            }
        }
    } else {
        NSString *currentUsername = (NSString*) [JNSimpleDataStore getValueForKey:kSGUsernameKey];
        if ([NSString isNotEmptyString:currentUsername]) {
            currentUser = [SGUser new];
            currentUser.username = currentUsername;
            [self.class saveCurrentUser:currentUser];
            return currentUsername;
        } else {
            return nil;
        }
    }
}

+ (void)fetchCurrentUserCompleted:(void(^)(SGUser *user))completed
                           failed:(void(^)(NSString *errorMessage))failed
{
    NSNumber *currentUserId = [self.class getCurrentUserId];
    if ([NSNumber isNotNullNumber:currentUserId]) {
        [[SGAPIClient sharedClient] getUserById:currentUserId.integerValue success:^(id object) {
            NSError *error;
            SGUser *currentUser = [MTLJSONAdapter modelOfClass:SGUser.class fromJSONDictionary:object error:&error];
            if (error) {
                [JNLogger logExceptionWithName:THIS_METHOD reason:@"error with init user" error:error];
            }
            completed(currentUser);
        } fail:^(NSString *errorMessage) {
            failed(errorMessage);
        }];
    } else {
        failed(JNLocalizedString(@"failed.request.user.details.alert.body"));
    }
}

+ (void)updateDeviceTokenForCurrentUser:(NSString*)deviceToken
                              completed:(void(^)())completed
                                 failed:(void(^)())failed
{
    [[SGAPIClient sharedClient] updateDeviceToken:deviceToken success:completed fail:failed];
}

+ (void)fetchFriendsCompleted:(void(^)(NSArray *friends))completed
                     failed:(void(^)(NSString *errorMessage))failed
{
    [self.class localFetchFriendsCompleted:^(NSArray *friends) {
        if (completed) completed(friends);
    } failed:^(NSString *errorMessage) {
        if (failed) failed(errorMessage);
    }];
}

+ (void)localFetchFriendsCompleted:(void(^)(NSArray *friends))completed
                       failed:(void(^)(NSString *errorMessage))failed
{
    NSString *statement = @"SELECT * FROM friends "
                           "ORDER BY name ASC";
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        // get # of videos for conversation
        FMResultSet *rs = [db executeQuery:statement];
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:1];
        while ([rs next]) {
            SGUser *friend = (SGUser*) [SGUser initFromJSONDictionary:rs.resultDictionary];
            [list addObject:friend];
        }
        if (completed) completed(list);
        [rs close];
    }];
}

+ (void)dropFriendsTablesCompleted:(void(^)())completed
{
    JNLog();
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DELETE FROM friends"];
		[db commit];
	}];
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DELETE FROM recent_friends"];
		[db commit];
	}];
    if (completed) completed();
}

+ (void)syncFriendsCompleted:(void(^)(NSDictionary *friendsMap))completed
                      failed:(void(^)(NSString *errorMessage))failed
{
    JNLog();
    [[SGAPIClient sharedClient] getFriendsSuccess:^(id data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            // recent friends
            NSArray *recentFriends = [data objectForKey:@"recent_friends"];
            [recentFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SGRecentFriend *recentFriend = (SGRecentFriend*) [SGRecentFriend initFromJSONDictionary:obj];
                [recentFriend save];
            }];
            // all friends
            NSArray *allFriends = [data objectForKey:@"friends"];
            [allFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SGFriend *friend = (SGFriend*) [SGFriend initFromJSONDictionary:obj];
                [friend save];
            }];
        } else if ([data isKindOfClass:[NSArray class]]) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SGFriend *friend = (SGFriend*) [SGFriend initFromJSONDictionary:obj];
                [friend save];
            }];
        }
        // complete
        if (completed) completed(nil);
    } fail:^(NSString *errorMessage) {
        if (failed) failed(errorMessage);
    }];
}

+ (void)fetchRecentAndAllFriendsCompleted:(void(^)(NSDictionary *friendsMap))completed
                                   failed:(void(^)(NSString *errorMessage))failed
{
    [self.class localFetchRecentAndAllFriendsCompleted:^(NSDictionary *friendsMap) {
        if (completed) completed(friendsMap);
    } failed:^(NSString *errorMessage) {
        if (failed) failed(errorMessage);
    }];
}

+ (void)localFetchRecentAndAllFriendsCompleted:(void(^)(NSDictionary *friendsMap))completed
                                   failed:(void(^)(NSString *errorMessage))failed
{
    NSMutableDictionary *friendsMap = [@{kSGRecentFriendsKey: @[], kSGAllFriendsKey: @[]} mutableCopy];
    
    // get recent friends
    NSMutableArray *recentFriends = [NSMutableArray arrayWithCapacity:1];
    NSString *recentFriendsStatement = @"SELECT * FROM recent_friends ORDER BY name ASC";
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:recentFriendsStatement];
        while (rs.next) {
            SGRecentFriend *recentFriend = (SGRecentFriend*) [SGRecentFriend initFromJSONDictionary:rs.resultDictionary];
            [recentFriends addObject:recentFriend];
        }
        [rs close];
    }];
    [friendsMap setObject:recentFriends forKey:kSGRecentFriendsKey];
    
    // get all friends
    NSMutableArray *allFriends = [NSMutableArray arrayWithCapacity:1];
    NSString *allFriendsStatement = @"SELECT * FROM friends ORDER BY name ASC";
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:allFriendsStatement];
        while (rs.next) {
            SGFriend *friend = (SGFriend*) [SGFriend initFromJSONDictionary:rs.resultDictionary];
            [allFriends addObject:friend];
        }
        [rs close];
    }];
    [friendsMap setObject:allFriends forKey:kSGAllFriendsKey];
    
    if (completed) {
        completed(friendsMap);
    }
}

+ (void)blockUserWithID:(NSNumber*)userID
              completed:(void(^)())completed
                 failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient] blockUser:userID
                                  success:^(id object){
                                      if (completed) completed();
                                  }fail:^(NSString *errorMessage){
                                      if (failed) failed(errorMessage);
                                  }];
}

+ (void)unblockUserWithID:(NSNumber*)userID
                completed:(void(^)())completed
                   failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient] unblockUser:userID
                                    success:^(id object){
                                        if (completed) completed();
                                    }fail:^(NSString *errorMessage){
                                        if (failed) failed(errorMessage);
                                    }];
}

+ (void)searchForUsername:(NSString*)username
                completed:(void(^)(NSArray *users))completed
                   failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient]
     searchForUsername:username
     success:^(id object) {
         if ([object respondsToSelector:@selector(enumerateObjectsUsingBlock:)]) {
             NSMutableArray *userResult = [NSMutableArray arrayWithCapacity:1];
             [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 SGContact *contact = [SGContact new];
                 contact = [SGContact parseJSONContact:obj];
                 [userResult addObject:contact];
             }];
             if (completed) completed(userResult);
         } else if ([object respondsToSelector:@selector(objectForKey:)]) {
             SGContact *contact = [SGContact new];
             contact = [SGContact parseJSONContact:object];
             if (completed) completed(@[contact]);
         } else {
             if (completed) completed(nil);
         }

     } fail:^(NSString *errorMessage) {
         if (failed) failed(errorMessage);
     }];
}

@end
