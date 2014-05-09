//
//  SGPendingVideo+Service.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGPendingVideo.h"

@interface SGPendingVideo (Service)

+ (void)printAll;

+ (void)fetchAllCompleted:(void(^)(NSArray *pendingVideos))completed;

+ (SGPendingVideo*)createPendingVideoWithVideoGUID:(NSString*)videoGUID
                                    conversationID:(NSNumber*)conversationID
                                    localVideoPath:(NSString*)localVideoPath
                                    localThumbPath:(NSString*)localThumbPath
                                          subtitle:(NSString*)subtitle;

+ (SGPendingVideo*)fetchByVideoGUID:(NSString*)videoGUID;

+ (void)notifyIncomingWithGUID:(NSString*)guid
                conversationID:(NSNumber*)conversationID
                     completed:(void(^)())completed
                        failed:(void(^)())failed;

- (NSString*)generateUploadedFileKey;

- (void)updateDidUploadVideo:(BOOL)didUploadVideo;

- (void)updateDidRemoteSave:(BOOL)didRemoteSave;

- (void)save;

- (void)remove;

@end
