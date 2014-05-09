//
//  SGConversationObject.m
//  HollerbackApp
//
//  Created by Kevin Coulton on 9/2/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <ReactiveCocoa.h>

#import "SGConversationObject.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

@implementation SGConversationObject
@synthesize name,
			videos,
			videoMetadata;

-(id) init
{
	if(self = [super init])
	{
		videos = [[NSMutableDictionary alloc] initWithCapacity:0];
		videoMetadata = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

// TODO this does not follow objective-c naming patterns, should be somethinglike objectWithConversationID
+ (SGConversationObject*)	initWithConversationID:(NSNumber*)convoID name:(NSString*)name;
{
	SGConversationObject *this = [[SGConversationObject alloc] init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"messages.db"];
	
	FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
	[dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:@"SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC",convoID];
		while ([rs next]) {
			JNLog(@"&&&& : %@",[[rs resultDictionary] description]);
			[this.videoMetadata addObject:[rs resultDictionary]];
		}
        if (db.lastError) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
	}];
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentDirectory = [paths objectAtIndex:0];
	dbPath = [documentDirectory stringByAppendingPathComponent:@"videos.db"];
	
	FMDatabaseQueue *vidQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
	[vidQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [FMResultSet alloc];
		rs = [db executeQuery:@"SELECT * FROM videos WHERE conversation_id = ?",convoID];
		while ([rs next]) {
			JNLog(@"$$$$ : %@",[[rs resultDictionary] description]);
			NSString *index = [NSString stringWithFormat:@"%@",[[rs resultDictionary] valueForKey:@"video_id"]];
			//NSString *index = [NSString stringWithFormat:@"%@",];
			[this.videos setObject:[rs resultDictionary] forKey:index];
		}
	}];
	
	for (id object in this.videoMetadata)
	{
		JNLog(@"#### %@", object);
	}
	
	[this setName:name];
	[this setConversationID:convoID];
	
	return this;
}

- (NSArray*)unwatchedVideosURLs
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == 0"];
    NSArray *unwatchedVideos = [self.videoMetadata filteredArrayUsingPredicate:predicate];
    if ([NSArray isNotEmptyArray:unwatchedVideos]) {
        NSArray *urls = [unwatchedVideos.rac_sequence map:^id(NSDictionary *video) {
            NSString *urlString = [video valueForKey:@"url"];
            if ([NSString isNotEmptyString:urlString]) {
                return [NSURL URLWithString:urlString];
            }
            return nil;
        }].array;
        return urls;
    }
    return nil;
}

+ (SGConversationObject*)fetchConversationWithID:(NSNumber*)conversationID
{
	SGConversationObject *this = [[SGConversationObject alloc] init];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"convos.db"];
	
	FMDatabaseQueue *vidQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
	[vidQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [FMResultSet alloc];
		rs = [db executeQuery:@"SELECT * FROM conversations WHERE conversation_id = ? LIMIT 1", conversationID];
		while ([rs next]) {
            this.conversationID = conversationID;
            this.name = [[rs resultDictionary] valueForKey:@"name"];
            this.unreadCount = [[rs resultDictionary] valueForKey:@"unread_count"];
		}
	}];
    JNLogObject(this);
    return this;
}

@end
