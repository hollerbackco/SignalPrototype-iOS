//
//  SGPendingVideo+Service.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGPendingVideo+Service.h"

#import "SGVideo+Service.h"

#import "SGAPIClient.h"

#define kSGIncomingVideoPath @"me/conversations/%@/videos/incoming"

@implementation SGPendingVideo (Service)

+ (void)printAll
{
    JNLog();
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM pending_videos"];
        while (rs.next) {
            SGPendingVideo *pendingVideo = (SGPendingVideo*) [SGPendingVideo initFromJSONDictionary:rs.resultDictionary];
            JNLogObject(pendingVideo);
        }
        [rs close];
    }];
}

+ (void)fetchAllCompleted:(void(^)(NSArray *pendingVideos))completed
{
    JNLog();
    NSMutableArray *allPendingVideos = [NSMutableArray arrayWithCapacity:1];
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM pending_videos"];
        while (rs.next) {
            SGPendingVideo *pendingVideo = (SGPendingVideo*) [SGPendingVideo initFromJSONDictionary:rs.resultDictionary];
            JNLogObject(pendingVideo);
            [allPendingVideos addObject:pendingVideo];
        }
        [rs close];
    }];
    if (completed) completed(allPendingVideos);
}

+ (SGPendingVideo*)createPendingVideoWithVideoGUID:(NSString*)videoGUID
                                    conversationID:(NSNumber*)conversationID
                                    localVideoPath:(NSString*)localVideoPath
                                    localThumbPath:(NSString*)localThumbPath
                                          subtitle:(NSString*)subtitle
{
    JNLog(@"%@: %@", conversationID, localVideoPath);
    SGPendingVideo *pendingVideo = [SGPendingVideo new];
    pendingVideo.videoGUID = videoGUID;
    pendingVideo.conversationID = conversationID;
    pendingVideo.status = @(kSGPendingVideoStatusNone);
    pendingVideo.localVideoPath = localVideoPath;
    pendingVideo.localThumbPath = localThumbPath;
    pendingVideo.subtitle = subtitle;
    pendingVideo.uploadRetryCount = @(0);
    pendingVideo.didUploadVideo = @(NO);
    pendingVideo.didRemoteSave = @(NO);
    return pendingVideo;
}

+ (SGPendingVideo*)fetchByVideoGUID:(NSString*)videoGUID
{
    JNLogObject(videoGUID);
    __block SGPendingVideo *pendingVideo = nil;
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:
                                  @"SELECT * FROM pending_videos "
                                  "WHERE video_guid = ?", videoGUID];
        while (rs.next) {
            pendingVideo = (SGPendingVideo*) [SGPendingVideo initFromJSONDictionary:rs.resultDictionary];
            break;
        }
        [rs close];
    }];
    return pendingVideo;
}

+ (void)notifyIncomingWithGUID:(NSString*)guid
                conversationID:(NSNumber*)conversationID
                     completed:(void(^)())completed
                        failed:(void(^)())failed
{
    NSMutableDictionary *parameters = [[SGAPIClient createAccessTokenParameter] mutableCopy];
    [parameters setObject:guid forKey:@"guid"];
    NSString *urlString = [NSString stringWithFormat:kSGIncomingVideoPath, conversationID];
    JNLogObject(urlString);
    JNLogObject(parameters);
    [[SGAPIClient sharedClient] POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JNLogObject(responseObject);
        if (completed) {
            completed();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JNLogger logExceptionWithName:THIS_METHOD reason:@"failed request" error:error];
        if (failed) {
            failed();
        }
    }];
}

- (NSString*)generateUploadedFileKey
{
    NSArray *components = [self.localVideoPath componentsSeparatedByString:@"/"];
    NSString *uploadedFileKey = nil;
    if (components && components.count > 1) {
        uploadedFileKey = [components objectAtIndex:components.count - 1];
    }
    JNLogObject(uploadedFileKey);
    return uploadedFileKey;
}

- (void)updateDidUploadVideo:(BOOL)didUploadVideo
{
    self.didUploadVideo = @(didUploadVideo);
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"UPDATE pending_videos "
             "SET did_upload_video = ? "
             "WHERE video_guid = ?",
             @(didUploadVideo),
             self.videoGUID]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

- (void)updateDidRemoteSave:(BOOL)didRemoteSave
{
    self.didRemoteSave = @(didRemoteSave);
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"UPDATE pending_videos "
             "SET did_remote_save = ? "
             "WHERE video_guid = ?",
             @(didRemoteSave),
             self.videoGUID]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

- (void)save
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if(![db executeUpdate:
             @"INSERT OR REPLACE INTO pending_videos ("
             @"id, "
             @"video_guid, "
             @"conversation_id, "
             @"status, "
             @"local_video_path, "
             @"local_thumb_path, "
             @"uploaded_file_key, "
             @"subtitle, "
             @"upload_retry_count, "
             @"did_upload_video, "
             @"did_remote_save, "
             @"created_at) "
             @"VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
             self.identifier,
             self.videoGUID,
             self.conversationID,
             self.status,
             self.localVideoPath,
             self.localThumbPath,
             self.uploadedFileKey,
             self.subtitle,
             self.uploadRetryCount,
             self.didUploadVideo,
             self.didRemoteSave,
             @([NSDate date].timeIntervalSince1970)]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

- (void)remove
{
    [[SGDatabase getDBQueue] inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        if (![db executeUpdate:
              @"DELETE FROM pending_videos WHERE video_guid = ?",
              self.videoGUID]) {
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:db.lastError];
        }
        [db commit];
    }];
}

@end
