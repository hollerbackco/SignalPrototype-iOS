//
//  SGRecentFriend+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 20/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGRecentFriend+Service.h"

@implementation SGRecentFriend (Service)

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO recent_friends ("
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

@end
