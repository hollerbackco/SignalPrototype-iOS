//
//  SGConversationObject.h
//  HollerbackApp
//
//  Created by Kevin Coulton on 9/2/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGConversationObject : NSObject

+ (SGConversationObject*)	initWithConversationID:(NSNumber*)convoID name:(NSString*)name;

@property (strong, nonatomic)	NSString*				name;
@property (strong, nonatomic)	NSNumber*				conversationID;
@property (strong, nonatomic)	NSNumber*				unreadCount;
@property (strong, nonatomic)	NSMutableDictionary*	videos;
@property (strong, nonatomic)	NSMutableArray*			videoMetadata;

- (NSArray*)unwatchedVideosURLs;

+ (SGConversationObject*)fetchConversationWithID:(NSNumber*)conversationID;

@end
