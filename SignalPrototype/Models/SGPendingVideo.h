//
//  SGPendingVideo.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 17/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "MTLJSONAdapter.h"

#import "SGBaseModel.h"

typedef enum {
    kSGPendingVideoStatusNone,
    kSGPendingVideoStatusUploadingFile,
    kSGPendingVideoStatusFileUploaded,
    kSGPendingVideoStatusVideoSaved
} kSGPendingVideoStatus;

@interface SGPendingVideo : SGBaseModel

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, copy) NSString *videoGUID;
@property (nonatomic, strong) NSNumber *conversationID;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *localVideoPath;
@property (nonatomic, copy) NSString *localThumbPath;
@property (nonatomic, copy) NSString *uploadedFileKey;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSNumber *uploadRetryCount;
@property (nonatomic, strong) NSNumber *didUploadVideo;
@property (nonatomic, strong) NSNumber *didRemoteSave;

@end
