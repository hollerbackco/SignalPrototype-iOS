//
//  SGUnaddedFriend+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGUnaddedFriend.h"

#define kSGSyncUnaddedFriendsCompleted @"kSGSyncUnaddedFriendsCompleted"
#define kSGClearNewUnaddedFriendsCompleted @"kSGClearNewUnaddedFriendsCompleted"

@interface SGUnaddedFriend (Service)

+ (BOOL)friendDoesExist:(NSString*)username;

+ (void)syncUnaddedFriendsWithNewFlag:(BOOL)isNew
                            completed:(void(^)(NSArray *unaddedFriends))completed
                               failed:(void(^)(NSString *errorMessage))failed;

+ (void)fetchUnaddedFriendsCompleted:(void (^)(NSArray *unaddedFriends))completed
                              failed:(void (^)(NSString *errorMessage))failed;

+ (BOOL)hasNewUnaddedFriends;

+ (void)clearNewUnaddedFriendsCompleted:(void (^)())completed
                              failed:(void (^)(NSString *errorMessage))failed;

- (void)save;

@end
