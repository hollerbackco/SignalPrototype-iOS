//
//  SGPendingVideo.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGPendingVideo.h"

@implementation SGPendingVideo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *superKeyPaths = [super JSONKeyPathsByPropertyKey];
    NSDictionary *selfKeyPaths = @{
                                   @"identifier": @"id",
                                   @"videoGUID": @"video_guid",
                                   @"conversationID": @"conversation_id",
                                   @"status": @"status",
                                   @"localVideoPath": @"local_video_path",
                                   @"localThumbPath": @"local_thumb_path",
                                   @"uploadedFileKey": @"uploaded_file_key",
                                   @"subtitle": @"subtitle",
                                   @"uploadRetryCount": @"upload_retry_count",
                                   @"didUploadVideo": @"did_upload_video",
                                   @"didRemoteSave": @"did_remote_save"
                                   };
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionaryWithCapacity:superKeyPaths.count + selfKeyPaths.count];
    [keyPaths addEntriesFromDictionary:superKeyPaths];
    [keyPaths addEntriesFromDictionary:selfKeyPaths];
    return keyPaths;
}

@end
