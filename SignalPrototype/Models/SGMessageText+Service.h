//
//  SGMessageText+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 8/04/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGMessageText.h"
#import "SGMessage.h"

@interface SGMessageText ()

@property (nonatomic, strong) SGMessage *message;

@end

@interface SGMessageText (Service)

#pragma mark - Fetch

+ (SGMessageText*)fetchMessageTextWithGUID:(NSString*)guid;

#pragma mark - Create

+ (void)createWithText:(NSString*)text
                  guid:(NSString*)guid
        conversationID:(NSNumber*)conversationID
             completed:(void(^)(SGMessageText *messageText))completed
                failed:(void(^)(NSString *errorMessage))failed;

#pragma mark - Save

- (void)save;

@end
