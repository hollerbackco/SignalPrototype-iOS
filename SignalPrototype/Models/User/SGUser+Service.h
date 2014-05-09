//
//  SGUser+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 29/10/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGUser.h"

#define kSGRecentFriendsKey @"recent_friends"
#define kSGAllFriendsKey @"friends"
#define kSGInviteFriendsKey @"invite_friends"

#define kSGSyncFriendsCompletedNotification @"kSGSyncFriendsCompletedNotification" 

@interface SGUser (Service)

+ (BOOL)isLoggedIn;

+ (void)saveCurrentUser:(SGUser*)currentUser;

+ (SGUser*)getCurrentUser;

+ (NSNumber*)getCurrentUserId;

+ (NSString*)getCurrentUsername;

+ (void)fetchCurrentUserCompleted:(void(^)(SGUser *user))completed
                           failed:(void(^)(NSString *errorMessage))failed;

+ (void)updateDeviceTokenForCurrentUser:(NSString*)deviceToken
                              completed:(void(^)())completed
                                 failed:(void(^)())failed;

+ (void)fetchFriendsCompleted:(void(^)(NSArray *friends))completed
                       failed:(void(^)(NSString *errorMessage))failed;

+ (void)dropFriendsTablesCompleted:(void(^)())completed;

+ (void)syncFriendsCompleted:(void(^)(NSDictionary *friendsMap))completed
                      failed:(void(^)(NSString *errorMessage))failed;

+ (void)fetchRecentAndAllFriendsCompleted:(void(^)(NSDictionary *friendsMap))completed
                                   failed:(void(^)(NSString *errorMessage))failed;

+ (void)blockUserWithID:(NSNumber*)userID
              completed:(void(^)())completed
                 failed:(void(^)(NSString *errorMessage))failed;

+ (void)unblockUserWithID:(NSNumber*)userID
                completed:(void(^)())completed
                   failed:(void(^)(NSString *errorMessage))failed;

+ (void)searchForUsername:(NSString*)username
                completed:(void(^)(NSArray *users))completed
                   failed:(void(^)(NSString *errorMessage))failed;

@end
