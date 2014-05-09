//
//  SGInvitee+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGInvitee+Service.h"
#import "SGContact+Service.h"

@implementation SGInvitee (Service)

+ (void)fetchInviteesForConversationID:(NSNumber*)conversationID
                             completed:(void(^)(NSArray *invitees))completed
                                failed:(void(^)())failed
{
    NSString *statement = [NSString stringWithFormat:@"SELECT * FROM invitees WHERE conversation_id = %@", conversationID];
    NSArray *allResults =
    [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchAllResultsWithStatement:statement, nil];
    NSMutableArray *invitees = [NSMutableArray arrayWithCapacity:1];
    [allResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGInvitee *invitee = (SGInvitee*) [SGInvitee initFromJSONDictionary:obj];
        [invitees addObject:invitee];
    }];
    JNLogPrimitive(invitees.count);
    if (completed) {
        completed(invitees);
    }
}

+ (void)saveInviteeFromObject:(id)obj withConversationID:(NSNumber*)conversationID
{
    if (!([obj respondsToSelector:@selector(name)] ||
        [obj respondsToSelector:@selector(username)]) &&
        !([obj respondsToSelector:@selector(phoneNumber)] ||
        [obj respondsToSelector:@selector(phoneNumbers)])) {
        return;
    }
    SGInvitee *invitee = [SGInvitee new];
    invitee.conversationID = conversationID;
    // set name
    if ([obj respondsToSelector:@selector(name)]) {
        invitee.name = [obj performSelector:@selector(name)];
    } else if ([obj respondsToSelector:@selector(username)]) {
        invitee.name = [obj performSelector:@selector(username)];
    } else {
        //
    }
    // set phone number
    if ([obj respondsToSelector:@selector(phoneNumber)]) {
        invitee.phoneNumber = [obj performSelector:@selector(phoneNumber)];
    } else {
        if ([obj respondsToSelector:@selector(primaryPhoneNumber)] &&
            [obj respondsToSelector:@selector(phoneNumbers)]) {
            NSString *primaryPhoneNumber = [obj performSelector:@selector(primaryPhoneNumber)];
            if ([NSString isNotEmptyString:primaryPhoneNumber]) {
                invitee.phoneNumber = primaryPhoneNumber;
            } else {
                NSArray *phoneNumbers = [obj performSelector:@selector(phoneNumbers)];
                if ([NSArray isNotEmptyArray:phoneNumbers]) {
                    invitee.phoneNumber = [phoneNumbers componentsJoinedByString:@","];
                }
            }
        }
    }
    [invitee save];
}

- (NSArray*)phoneNumberToArray
{
    return [self.phoneNumber componentsSeparatedByString:@","];
}

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO invitees ("
             @"id, "
             @"conversation_id, "
             @"name, "
             @"phone_number, "
             @"created_at, "
             @"updated_at) "
             @"VALUES (?,?,?,?,?,?)",
             self.identifier,
             self.conversationID,
             self.name,
             self.phoneNumber,
             @(self.createdAt.timeIntervalSince1970),
             @(self.updatedAt.timeIntervalSince1970)]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

@end
