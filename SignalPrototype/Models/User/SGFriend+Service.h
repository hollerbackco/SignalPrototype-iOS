//
//  SGFriend+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 20/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGFriend.h"

@interface SGFriend (Service)

+ (void)addFriendsWithUsernames:(NSArray*)usernames
                      completed:(void(^)())completed
                         failed:(void(^)())failed;

- (void)save;

- (void)remove;

@end
