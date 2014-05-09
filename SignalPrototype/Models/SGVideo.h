//
//  SGVideo.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "SGBaseModel.h"

typedef enum {
    kSGVideoThumbGravityNone,
    kSGVideoThumbGravityLeft,
    kSGVideoThumbGravityCenter,
    kSGVideoThumbGravityRight
} kSGVideoThumbGravity;

typedef enum {
    kSGVideoThumbStyleNone,
    kSGVideoThumbStyleRound,
    kSGVideoThumbStyleSquare
} kSGVideoThumbStyle;

@interface SGVideo : SGBaseModel

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, strong) NSNumber *conversationID;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbURL;
@property (nonatomic, copy) NSString *gifURL;
@property (nonatomic, strong) NSNumber *isRead;
@property (nonatomic, copy) NSNumber *senderID;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, strong) NSDate *sentAt;
@property (nonatomic, strong) NSNumber *needsReply;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSNumber *thumbGravity;
@property (nonatomic, strong) NSNumber *thumbStyle;
@property (nonatomic, strong) NSNumber *fileDownloaded;

+ (NSNumber*)numberFromThumbGravityString:(NSString*)thumbGravity;
+ (NSString*)stringFromThumbGravityNumber:(NSNumber*)thumbGravity;
+ (NSNumber*)numberFromThumbStyleString:(NSString*)thumbStyle;
+ (NSString*)stringFromThumbStyleNumber:(NSNumber*)thumbStyle;

- (NSString*)localFilePath;
- (NSURL*)videoURL;

@end
