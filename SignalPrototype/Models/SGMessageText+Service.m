//
//  SGMessageText+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMessageText+Service.h"
#import "SGAPIClient.h"

@implementation SGMessageText (Service)

#pragma mark - Fetch

+ (SGMessageText*)fetchMessageTextWithGUID:(NSString*)guid
{
    id messageTextResult = [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchFirstResultWithStatement:
                        @"SELECT * FROM message_texts "
                        "WHERE guid = ?",
                        guid, nil];
    
    SGMessageText *messageText;
    if (messageTextResult) {
        messageText = (SGMessageText*) [SGMessageText initFromJSONDictionary:messageTextResult];
    }
    return messageText;
}

#pragma mark - Create

+ (void)createWithText:(NSString*)text
                  guid:(NSString*)guid
        conversationID:(NSNumber*)conversationID
             completed:(void(^)(SGMessageText *messageText))completed
                failed:(void(^)(NSString *errorMessage))failed
{
    [[SGAPIClient sharedClient] 
     createText:text
     guid:guid
     conversationID:conversationID
     retryNumberOfTimes:kSGTextRetryNumberOfTimes
     success:^(id object) {
         SGMessageText *messageText;
         if (object) {
             messageText = (SGMessageText*) [SGMessageText initFromJSONDictionary:object];
             [messageText save];
         }
         if (completed) {
             completed(messageText);
         }
    } fail:^(NSString *errorMessage) {
        if (failed) {
            failed(errorMessage);
        }
    }];
}

#pragma mark - Save

- (void)save
{
    JNAssert(self.guid);
    JNAssert(self.text);
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"INSERT OR REPLACE INTO message_texts ("
     "guid,"
     "text"
     ") "
     "VALUES (?,?)"
     arguments:
     @[self.guid,
       self.text] completed:^(NSError *error) {
           ;
       }];
}

@end
