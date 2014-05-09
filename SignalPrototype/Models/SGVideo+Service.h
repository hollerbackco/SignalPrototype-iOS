//
//  SGVideo+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGVideo.h"

#define kSGFetchVideosByConversationID @"/api/me/conversations/%@/videos"

@interface SGVideo (Service)

+ (SGVideo*)initVideoFromJSONDictionary:(NSDictionary*)jsonDictionary;

#pragma mark - Helpers

+ (BOOL)hasUnwatchedVideos:(NSArray*)videos;

+ (NSURL*)generateThumbnailFromVideoURL:(NSURL*)videoURL;

#pragma mark - Fetch

+ (SGVideo*)fetchVideoWithGUID:(NSString*)guid;

#pragma mark - Create

+ (void)createVideoWithParts:(NSArray*)partFileNames
                        guid:(NSString*)guid
              conversationId:(NSUInteger)conversationId
                  watchedIds:(NSArray *)watchedIds
                     isReply:(BOOL)isReply
                    subtitle:(NSString*)subtitle
                   thumbPath:(NSString*)thumbPath
                   videoPath:(NSString*)videoPath
                   completed:(void(^)(SGVideo *video))completed
                      failed:(void(^)(NSString *guid))failed;

#pragma mark - Save

- (void)save;

#pragma mark -

+ (BOOL)updateVideosMarkAsWatched:(NSArray*)videos;

- (void)markAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed;

- (void)localMarkAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed;

- (void)remoteMarkAsWatchedCompleted:(void(^)())completed failed:(void(^)())failed;

- (void)updateFileDownloaded:(BOOL)fileDownloaded completed:(void(^)())completed;

@end
