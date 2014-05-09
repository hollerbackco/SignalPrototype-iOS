//
//  SGMembership+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/01/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMembership+Service.h"
#import "SGDatabase.h"
#import "SGAPIClient.h"

@implementation SGMembership (Service)

+ (void)getMembersWithConversationID:(NSNumber*)conversationID
                           completed:(void(^)(NSArray *members))completed
                              failed:(void(^)(NSString *errorMessage))failed
{
    [self.class remoteFetchMembersWithConversationID:conversationID completed:completed failed:failed];
}

+ (void)remoteFetchMembersWithConversationID:(NSNumber*)conversationID
                                   completed:(void(^)(NSArray *members))completed
                                      failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient] getMembersForConversationID:conversationID success:^(NSArray *members) {
        __block NSMutableArray *list = [NSMutableArray arrayWithCapacity:members.count];
        [members enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            SGMembership *member = (SGMembership*) [SGMembership initFromJSONDictionary:dict];
            [list addObject:member];
        }];
        if (completed) {
            completed(list);
        }
    } fail:^(NSString *errorMessage) {
        if (failed) failed(errorMessage);
    }];
}

@end
