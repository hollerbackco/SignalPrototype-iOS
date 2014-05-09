//
//  SGVideo+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <MTLJSONAdapter.h>
#import <EXTScope.h>
#import <AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

#import "SGVideo+Service.h"
#import "SGAPIClient.h"
#import "JNSimpleDataStore.h"
#import "SGDatabase.h"
#import "SGConversation+Service.h"

@implementation SGVideo (Service)

+ (SGVideo*)initVideoFromJSONDictionary:(NSDictionary*)jsonDictionary
{
    NSError *error;
    SGVideo *video = [MTLJSONAdapter modelOfClass:SGVideo.class fromJSONDictionary:jsonDictionary error:&error];
    NSDictionary *display = [jsonDictionary objectForKey:@"display"];
    if (display && [display isKindOfClass:[NSDictionary class]]) {
        [self.class populateVideo:video displayProperties:display];
    } else {
        [self.class populateVideo:video displayProperties:jsonDictionary];
    }
    if (!video) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"error processing video" error:error];
    }
    return video;
}

+ (void)populateVideo:(SGVideo*)video displayProperties:(NSDictionary*)jsonDictionary
{
    NSString *thumbGravity = [jsonDictionary objectForKey:@"thumb_gravity"];
    if ([NSString isNotEmptyString:thumbGravity]) {
        video.thumbGravity = [SGVideo numberFromThumbGravityString:thumbGravity];
    } else if ([NSNumber isNotNullNumber:thumbGravity]) {
        video.thumbGravity = (NSNumber*) thumbGravity;
    }
    NSString *thumbStyle = [jsonDictionary objectForKey:@"thumb_style"];
    if ([NSString isNotEmptyString:thumbStyle]) {
        video.thumbStyle = [SGVideo numberFromThumbStyleString:thumbStyle];
    } else if ([NSNumber isNotNullNumber:thumbStyle]) {
        video.thumbStyle = (NSNumber*) thumbStyle;
    }
}

#pragma mark - Helpers

+ (BOOL)hasUnwatchedVideos:(NSArray*)videos
{
    JNLog();
    __block BOOL hasUnwatchedVideos = NO;
    [videos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SGVideo class]]) {
            if (!((SGVideo*) obj).isRead.boolValue) {
                hasUnwatchedVideos = YES;
                *stop = YES;
            }
        }
    }];
    JNLogPrimitive(hasUnwatchedVideos);
    return hasUnwatchedVideos;
}

+ (NSURL*)generateThumbnailFromVideoURL:(NSURL*)videoURL
{
    if (!videoURL) {
        return nil;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    NSData *data = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
    NSString *thumbFilename = [videoURL.relativePath stringByReplacingOccurrencesOfString:kSGVideoExtension withString:kSGThumbnailExtension];
    NSURL *thumbURL = [NSURL fileURLWithPath:thumbFilename isDirectory:NO];
    NSError *error;
    if (![data writeToURL:thumbURL options:0 error:&error]) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"Error writing thumb" error:error];
    } else {
        JNLog(@"saved thumb with url: %@", videoURL);
    }
    return thumbURL;
}

#pragma mark - Fetch

+ (SGVideo*)fetchVideoWithGUID:(NSString*)guid
{
    id result = [SGDatabase DBQueue:[SGDatabase getDBQueue] fetchFirstResultWithStatement:
                            @"SELECT * FROM videos "
                            "WHERE guid = ?",
                            guid, nil];
    SGVideo *video;
    if (result) {
        video = (SGVideo*) [SGVideo initVideoFromJSONDictionary:result];
    }
    return video;
}

+ (void)remoteFetchVideosByConversationID:(NSNumber*)conversationID
                                  success:(void(^)(NSArray*))success
                                     fail:(void(^)(NSString*))fail
{
    NSDictionary *parameters = @{@"access_token": [JNSimpleDataStore getValueForKey:kSGAccessTokenKey]};
    NSString *path = [NSString stringWithFormat:kSGFetchVideosByConversationID, conversationID];
    [[SGAPIClient sharedClient] GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data;
        NSDictionary *responseJSON = (NSDictionary*) responseObject;
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
            data = [responseObject valueForKeyPath:@"data"];
        }
        if (data && [data isKindOfClass:NSArray.class]) {
            !success ?: success(data);
        } else {
            !fail ?: fail(@"parse error");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"client error" error:error];
        !fail ?: fail(@"error");
    }];
}

+ (void)remoteFetchRecentlyWatchedVideosByConversationID:(NSNumber*)conversationID
                                              pageNumber:(NSNumber*)pageNumber
                                                 success:(void(^)(NSArray*))success
                                                    fail:(void(^)(NSString*))fail
{
    NSString *path = [NSString stringWithFormat:kSGFetchVideosByConversationID, conversationID];
    NSMutableDictionary *parameters = [[SGAPIClient createAccessTokenParameter] mutableCopy];
    [parameters setValue:pageNumber forKey:@"page"];
    [parameters setValue:@(kSGVideoPlaybackNumberOfRecentlyWatchedVideos) forKey:@"perPage"];
    [[SGAPIClient sharedClient] GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data;
        NSDictionary *responseJSON = (NSDictionary*) responseObject;
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
            data = [responseObject valueForKeyPath:@"data"];
        }
        if (data && [data isKindOfClass:NSArray.class]) {
            NSMutableArray *recentVideos = [NSMutableArray arrayWithCapacity:1];
            if ([NSArray isNotEmptyArray:data]) {
                for (id jsonDictionary in data) {
                    if ([jsonDictionary isKindOfClass:[NSDictionary class]]) {
                        // create video from JSON
                        SGVideo *video = [SGVideo initVideoFromJSONDictionary:jsonDictionary];
                        [video save];
                        [recentVideos addObject:video];
                    }
                }
            }
            if (success) success(recentVideos);
        } else {
            if (fail) fail(@"parse error");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"client error" error:error];
        if (fail) fail(@"error");
    }];
}

#pragma mark - Create

+ (void)createVideoWithParts:(NSArray*)partFileNames
                        guid:(NSString*)guid
              conversationId:(NSUInteger)conversationID
                  watchedIds:(NSArray *)watchedIds
                     isReply:(BOOL)isReply
                    subtitle:(NSString*)subtitle
                   thumbPath:(NSString*)thumbPath
                   videoPath:(NSString*)videoPath
                   completed:(void(^)(SGVideo *video))completed
                      failed:(void(^)(NSString *guid))failed
{
    JNLog();
    // ensure part_urls are alphabetically sorted
    partFileNames = [partFileNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NSString*) obj1) compare:(NSString*) obj2];
    }];
    if ([NSString isNullOrEmptyString:guid]) {
        // create guid
        guid = [SGVideo generateGUID];
    }
    [[SGAPIClient sharedClient]
     createVideoWithGUID:guid
     parts:partFileNames
     conversationId:conversationID
     watchedIds:watchedIds
     isReply:isReply
     subtitle:subtitle
     retryNumberOfTimes:kSGVideoPartsRetryNumberOfTimes
     success:^(id object) {
         JNLogObject(object);
         SGVideo *video = [SGVideo initVideoFromJSONDictionary:object];
         video.isRead = @(YES);
         if ([NSString isNotEmptyString:thumbPath]) {
             video.thumbURL = thumbPath;
         }
         if ([NSString isNotEmptyString:videoPath]) {
             video.url = videoPath;
         }
         // thumb gravity
         video.thumbGravity = @(kSGVideoThumbGravityRight);
         video.thumbStyle = @(kSGVideoThumbStyleNone);
         if (!video.sentAt) {
             video.sentAt = [NSDate date];
         }
         // sender id
         NSNumber *senderId = [object objectForKey:@"user_id"];
         if ([NSNumber isNotNullNumber:senderId]) {
             video.senderID = senderId;
         }
         [video save];
         if (completed) completed(video);
     }
     fail:^(NSString *errorMessage) {
         JNLogObject(errorMessage);
         if (failed) failed(guid);
     }];
}

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO videos ("
             @"guid, "
             @"id, "
             @"conversation_id, "
             @"created_at, "
             @"isRead, "
             @"sender_id, "
             @"sender_name, "
             @"sent_at, "
             @"thumb_url, "
             @"gif_url, "
             @"updated_at, "
             @"url, "
             @"needs_reply, "
             @"subtitle,"
             @"thumb_gravity,"
             @"thumb_style,"
             @"file_downloaded) "
             @"VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
             self.guid,
             self.identifier,
             self.conversationID,
             @(self.createdAt.timeIntervalSince1970),
             self.isRead,
             self.senderID,
             self.senderName,
             @(self.sentAt.timeIntervalSince1970),
             self.thumbURL,
             self.gifURL,
             @(self.updatedAt.timeIntervalSince1970),
             self.url,
             self.needsReply,
             self.subtitle,
             self.thumbGravity,
             self.thumbStyle,
             self.fileDownloaded]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        
        [db commit];
    }];
}

#pragma mark - 

+ (BOOL)updateVideosMarkAsWatched:(NSArray*)videos
{
    JNLog();
    BOOL updated = NO;
    for(SGVideo *video in videos) {
        if (!video.isRead.boolValue) {
            [video localMarkAsWatchedCompleted:nil failed:nil];
            updated = YES;
        }
    }
    JNLogObject(@(updated));
    return updated;
}

- (void)markAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed
{
    JNLog();
    [self localMarkAsWatchedCompleted:^{
        if (completed) {
            completed();
        }
        // perform remote save
        [self remoteMarkAsWatchedCompleted:nil failed:nil];
    } failed:^{
        if (failed) failed();
    }];
}

- (void)remoteMarkAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed
{
    [[SGAPIClient sharedClient] markVideoAsWatched:self.guid success:^(id object) {
        if (completed) completed();
    } fail:^(NSString *errorMessage) {
        [self localMarkAsUnwatchedCompleted:^{
            if (failed) failed();
        } failed:failed];
    }];
}

- (void)localMarkAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed
{
    NSString *statement = @"UPDATE videos SET isRead = 1 WHERE guid = ?";
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        JNLog(@"set message as read");
        if(![db executeUpdate:statement, self.guid]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
            if (failed) failed();
        } else {
            JNLog(@"Did change %d rows", [db changes]);
        }
        [db commit];
		JNLog(@"MARKED VIDEO AS WATCHED");
	}];
    if (completed) completed();
}

- (void)localMarkAsUnwatchedCompleted:(void(^)())completed failed:(void(^)())failed
{
    NSString *statement = @"UPDATE videos SET isRead = 0 WHERE guid = ?";
    // Save info locally
	[[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        JNLog(@"set message as unwatched");
        if(![db executeUpdate:statement, self.guid]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
            if (failed) failed();
        } else {
            JNLog(@"Did change %d rows", [db changes]);
        }
        [db commit];
		JNLog(@"MARKED VIDEO AS UNWATCHED");
	}];
    if (completed) completed();
}

- (void)updateFileDownloaded:(BOOL)fileDownloaded completed:(void(^)())completed
{
    [SGDatabase
     DBQueue:[SGDatabase getDBQueue]
     updateWithStatement:
     @"UPDATE videos "
     "SET file_downloaded = ? "
     "WHERE guid = ?"
     arguments:@[@(fileDownloaded), self.guid]];
    
    if (completed) {
        completed();
    }
}

@end
