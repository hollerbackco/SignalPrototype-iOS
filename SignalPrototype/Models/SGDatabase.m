//
//  SGDatabase.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGDatabase.h"

@interface SGDatabase ()

+ (NSString*)getDBPath:(NSString*)dbFilename;

@end

@implementation SGDatabase

+ (FMDatabaseQueue*)getDBQueue
{
    return [FMDatabaseQueue databaseQueueWithPath:[SGDatabase getDBPath:@"hb.db"]];
}

+ (void)resetAllTables
{
    JNLog();
    [self dropAllTables];
    [self buildAllTables];
}

+ (void)resetConversationTables
{
    JNLog();
    [self dropConversationTables];
    [self buildConversationTables];
}


+ (void)buildAllTables
{
    [self.class buildConversationTables];
    [self.class buildFriendTables];
}

+ (void)buildConversationTables
{
    JNLog();
    
    NSString *sqlStatement =
    @"CREATE TABLE IF NOT EXISTS messages ("
    "content_guid text PRIMARY KEY NOT NULL,"
    "created_at integer,"
    "updated_at integer,"
    "conversation_id integer,"
    "type text,"
    "sent_at integer,"
    "sender_id integer,"
    "sender_name integer,"
    "is_read integer"
    ")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS videos ("
    @"guid text PRIMARY KEY NOT NULL,"
    @"id integer,"
    @"conversation_id integer,"
    @"created_at integer,"
    @"isRead bool,"
    @"sender_id integer,"
    @"sender_name text,"
    @"sent_at integer,"
    @"thumb_url text,"
    @"gif_url text,"
    @"updated_at integer,"
    @"url text,"
    @"needs_reply bool,"
    @"subtitle text,"
    @"thumb_gravity integer,"
    @"thumb_style integer,"
    @"file_downloaded integer"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
        [db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS message_texts ("
    "guid text PRIMARY KEY NOT NULL,"
    "id integer,"
    "created_at integer,"
    "updated_at integer,"
    "text text"
    ")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
	
    sqlStatement =
        @"CREATE TABLE IF NOT EXISTS conversations ("
        @"conversation_id integer PRIMARY KEY,"
        @"last_message_at integer,"
        @"name text,"
        @"most_recent_thumb_url text,"
        @"most_recent_subtitle text,"
        @"unread_count integer,"
        @"is_deleted bool,"
        @"color_code integer,"
        @"background_image_number integer,"
        @"sender_name text,"
        @"following integer"
        @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS pending_videos ("
    @"id integer PRIMARY KEY,"
    @"video_guid text, "
    @"conversation_id integer, "
    @"status integer, "
    @"local_video_path text, "
    @"local_thumb_path text, "
    @"uploaded_file_key text, "
    @"subtitle text, "
    @"upload_retry_count integer, "
    @"did_upload_video integer, "
    @"did_remote_save integer, "
    @"created_at integer"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS schema_app_version ("
    @"id integer PRIMARY KEY,"
    @"app_version text,"
    @"created_at integer,"
    @"updated_at integer"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS invitees ("
    @"id integer PRIMARY KEY,"
    @"conversation_id integer,"
    @"name text,"
    @"phone_number text,"
    @"created_at integer,"
    @"updated_at integer"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
}


+ (void)buildFriendTables
{
    NSString *sqlStatement =
    @"CREATE TABLE IF NOT EXISTS friends ("
    @"id integer,"
    @"name text, "
    @"username text PRIMARY KEY NOT NULL"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS recent_friends ("
    @"id integer,"
    @"name text, "
    @"username text PRIMARY KEY NOT NULL"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
    
    sqlStatement =
    @"CREATE TABLE IF NOT EXISTS unadded_friends ("
    @"id integer,"
    @"name text, "
    @"username text PRIMARY KEY NOT NULL, "
    @"is_new bool"
    @")";
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		if(![db executeUpdate:sqlStatement]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
		}
		[db commit];
	}];
}

+ (void)dropAllTables
{
    [self.class dropConversationTables];
    [self.class dropFriendTables];
    [self.class dropPendingVideosTable];
}

+ (void)dropConversationTables
{
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DROP TABLE IF EXISTS messages"];
		[db executeUpdate:@"DROP TABLE IF EXISTS message_texts"];
		[db executeUpdate:@"DROP TABLE IF EXISTS videos"];
		[db executeUpdate:@"DROP TABLE IF EXISTS conversations"];
		[db executeUpdate:@"DROP TABLE IF EXISTS invitees"];
		[db commit];
	}];
}

+ (void)dropFriendTables
{
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DROP TABLE IF EXISTS friends"];
		[db commit];
	}];
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DROP TABLE IF EXISTS recent_friends"];
		[db commit];
	}];
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DROP TABLE IF EXISTS unadded_friends"];
		[db commit];
	}];
}

+ (void)dropPendingVideosTable
{
	[[self getDBQueue] inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		[db executeUpdate:@"DROP TABLE IF EXISTS pending_videos"];
		[db commit];
	}];
}

- (void)printDB;
{    
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *fileExists = [NSString stringWithFormat:@"SELECT * FROM conversations"];
        JNLog(@"%@",fileExists);
        
        FMResultSet *resultSet = [FMResultSet alloc];
        resultSet = [db executeQuery:fileExists];
        int count = 0;
        while([resultSet next])
        {
            JNLog(@"%@", [[resultSet resultDictionary] description]);
            count ++;
        }	JNLog(@"TABLE conversations COUNT : %d",count);
        [db closeOpenResultSets];
	}];
}

+ (NSString*)getDBPath:(NSString*)dbFilename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:dbFilename];
}

#pragma mark - Fetches

+ (id)DBQueue:(FMDatabaseQueue*)dbQueue fetchFirstResultWithStatement:(id)statement, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, statement);
    NSMutableArray *arguments = [@[] mutableCopy];
    id arg = va_arg(args, id);
    if (arg) {
        do {
            [arguments addObject:arg];
            arg = va_arg(args, id);
        } while (arg != nil);
    }
    va_end(args);
    
    __block id firstResult = nil;
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result;
        if ([NSArray isNotEmptyArray:arguments]) {
            result = [db executeQuery:statement withArgumentsInArray:arguments];
        } else {
            result = [db executeQuery:statement];
        }
        while (result.next) {
            firstResult = result.resultDictionary;
        }
        [result close];
    }];
    return firstResult;
}

+ (NSArray*)DBQueue:(FMDatabaseQueue*)dbQueue fetchAllResultsWithStatement:(NSString*)statement, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, statement);
    NSMutableArray *arguments = [@[] mutableCopy];
    id arg = va_arg(args, id);
    if (arg) {
        do {
            [arguments addObject:arg];
            arg = va_arg(args, id);
        } while (arg != nil);
    }
    va_end(args);
    
    __block NSMutableArray *allResults = [NSMutableArray arrayWithCapacity:1];
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result;
        if ([NSArray isNotEmptyArray:arguments]) {
            result = [db executeQuery:statement withArgumentsInArray:arguments];
        } else {
            result = [db executeQuery:statement];
        }
        while (result.next) {
            [allResults addObject:result.resultDictionary];
        }
        [result close];
    }];
    return allResults;
}

#pragma mark - Updates

+ (void)DBQueue:(FMDatabaseQueue*)dbQueue
updateWithStatement:(NSString*)statement
      arguments:(NSArray*)arguments
      completed:(void(^)(NSError *error))completedBlock
{
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        BOOL result = NO;
        if ([NSArray isNotEmptyArray:arguments]) {
            result = [db executeUpdate:statement withArgumentsInArray:arguments];
        } else {
            result = [db executeUpdate:statement];
        }
        if(!result) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
        
        if (completedBlock) {
            NSError *error = nil;
            if (db.hadError) {
                error = db.lastError;
            }
            completedBlock(error);
        }
    }];
}

@end
