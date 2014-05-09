//
//  SGConstants.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 15/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SGServerConstants.h"

@interface SGConstants : NSObject

#define kSGRequestHeaderAppVersion @"iOS-App-Ver"
#define kSGRequestHeaderModelName @"iOS-Model-Name"
#define kSGRequestHeaderVersionName @"iOS-Version"
#define kSGRequestHeaderAccept @"Accept"
#define kSGRequestHeaderAPIVersion @"application/vnd.co.hollerback-v1+json"

#if ENTERPRISE
#define kSGisEnterpriseBuild 1
#else
#define kSGisEnterpriseBuild 0
#endif

#define kSGKeyboardHeight 216.0
#define kSGDefaultTextFieldHeight 31.0
#define kSGDefaultAnimationDuration UINavigationControllerHideShowBarDuration
#define kSGDefaultNavigationAndStatusBarHeight 64.0

#define kSGSyncPostNotificationName @"kSGSyncPostNotificationName"
#define kSGSyncUserInfoConvosKey @"convos"
#define kSGSyncUserInfoMessagesKey @"messages"

extern CGFloat const kSGRetrySyncDelay;
extern NSUInteger const kSGRetryCount;

// API
extern NSString * const kSGAPIPlatform;
extern NSString * const kSGConversationsLastUpdatedAt;

// Sync
extern NSUInteger const kSGSyncPaginationCount;

// Amazon
extern NSString * const kSGAmazonS3AccessKeyID;
extern NSString * const kSGAmazonS3SecretKey;
extern NSString * const kSGAmazonS3TempBucket;
extern NSString * const kSGAmazonS3RequestContentTypeVideo;
extern NSString * const kSGAmazonS3RequestContentTypeJPGImage;
extern NSString * const kSGAmazonS3RequestContentTypePNGImage;
extern NSString * const kSGAmazonS3RequestContentTypePlainText;
extern CGFloat const kSGAmazonPreSignedRequestExpireSeconds;

// Welcome Flow
extern NSUInteger const kSGHowItWorksConversationID;
extern NSString * const kSGHowItWorksThumbPath;
extern NSString * const kSGHowItWorksVideoResourceName;
extern NSString * const kSGHowItWorksVideoResourceType;

// Contacts
extern NSUInteger const SGContactsCheckMaxPhoneNumbers;

// Uploads
extern NSTimeInterval const kSGTransferManagerTimeout;
extern NSTimeInterval const kJNLogFileUploadTimeout;
extern CGFloat const kSGVideoUploadChunkLength;
extern NSUInteger const kSGVideoUploadMaxChunks;
extern CGFloat const kSGVideoMaxRecordTime;
extern NSTimeInterval const kSGVideoUploadChunkTimeout;
extern NSTimeInterval const kSGFullVideoUploadTimeout;
extern NSTimeInterval const kSGPendingVideoUploadTimeout;

// File/Folders
extern NSString * const kSGTempFolder;
extern NSString * const kSGTempVideosFolder;
extern NSInteger const kSGDeleteTempVideosLastModifiedDaysAgo;

// Video
#define kAVCaptureSessionPreset AVCaptureSessionPreset640x480
extern CGFloat const kSGVideoRecordingMinStartTime;
extern CGFloat const kSGVideoRecordingWarningEndTime; // time to display warning when recording has almost finished
extern CGFloat const kSGVideoCaptureWidth;
extern CGFloat const kSGVideoCaptureHeight;
extern CGFloat const kSGVideoFramesPerSecond;
extern CGFloat const kSGVideoBitRate;
// old
extern CGFloat const kSGVideoBitsPerPixel;
extern CGFloat const kSGCameraBlurRadius;
extern CGFloat const kSGThumbBlurRadius;
extern CGFloat const kSGVideoPartsSaveTimeout;

// Video Send
extern CGFloat const kSGVideoPartsSaveTimeout;
extern NSUInteger const kSGVideoPartsRetryNumberOfTimes;
extern CGFloat const kSGVideoPartsRetryDelay;

// Text Save
extern CGFloat const kSGTextSaveTimeout;
extern NSUInteger const kSGTextRetryNumberOfTimes;
extern CGFloat const kSGTextRetryDelay;

// Video playback
extern NSTimeInterval const kSGVideoPlaybackLoadingTimeout;
extern CGFloat const kSGVideoPlaybackLoadingProgressTimeout;
extern NSUInteger const kSGVideoPlaybackNumberOfRecentlyWatchedVideos;

// Messages
extern NSUInteger const kSGNumberOfRecentlyReadMessages;
extern NSTimeInterval const kSGSecondsBetweenMessagesForGrouping;

// Thread View
extern NSTimeInterval const kSGSecondsBetweenVideosForGrouping;

// Alert view
extern CGFloat const kSGAlertViewSavedDelay;

// Notifications
extern NSString * const SGShouldRefreshConversationsNotification;
extern NSString * const SGNewVideosReceivedNotification;

// Filenames
extern NSString * const kSGVideoExtension;
extern NSString * const kSGThumbnailExtension;
extern NSString * const kSGSMSVideoFilename;

// iPhone sizes
extern CGFloat const kSGiPhoneHeight3_5inch;
extern CGFloat const kSGiPhoneHeight4inch;
extern CGFloat const kSGiPhoneStatusBarHeight;
extern CGFloat const kSGiPhoneNavBarHeight;

// View
extern NSString * const SGVideoPaginationStoreKey;

// View Tags
extern int const SGLoadingSpinnerViewTag;
extern int const SGVideoPlayerLoadingSpinnerTag;
extern int const SGVideoPaginationLoadingSpinnerTag;
extern int const SGGroupInfoViewTag;
#define SGKeyboardOverlayTag 999995

// Country Code
extern int const SGDefaultCountryCode;
extern NSString * const SGDefaultRegion;

// Recording Tutorial
extern CGFloat const kSGTutorialReleaseHoldTime1;
extern CGFloat const kSGTutorialReleaseHoldTime2;
extern CGFloat const kSGTutorialReleaseHoldTime3;

+ (BOOL)is4InchiPhone;

// Keen Metrics
extern NSString * const SGKeenDefaultPropertyUserID;
extern NSString * const SGKeenDefaultPropertyAppVersion;
extern NSString * const SGKeenDefaultPropertySkippedTutorial;
extern NSString * const SGKeenDrawerOpen;
extern NSString * const SGKeenVideoDownload;
extern NSString * const SGKeenVideoUploadStart;
extern NSString * const SGKeenVideoUploadFirstFail;
extern NSString * const SGKeenVideoUploadCancel;
extern NSString * const SGKeenVideoUploadComplete;
extern NSString * const SGKeenVideoUploadRetries;
extern NSString * const SGKeenVideoUploadTimeToUpload;
extern NSString * const SGKeenAutoRespondStart;
extern NSString * const SGKeenAutoRespondQuit;
extern NSString * const SGKeenAutoRespondSend;
extern NSString * const SGKeenBuildContactsTime;
extern NSString * const SGKeenQuitCamera;
extern NSString * const SGKeenQuitPlayback;
extern NSString * const SGKeenDidFlipCamera;
extern NSString * const SGKeenVideoRecordFailure;
extern NSString * const SGKeenConversationHistory;
extern NSString * const SGKeenNewConversationSMSSend;
extern NSString * const SGKeenNewConversationSMSCancel;
extern NSString * const SGKeenFindFriendsSMSSend;
extern NSString * const SGKeenFindFriendsSMSCancel;
extern NSString * const SGKeenFindFriendsEmailSend;
extern NSString * const SGKeenFindFriendsEmailCancel;
extern NSString * const SGKeenVideoTTYLSend;
extern NSString * const SGKeenVideoTTYLCancel;
extern NSString * const SGKeenErrorVideoPartsTimeout;
extern NSString * const SGKeenException;
extern NSString * const SGKeenCostumeName;
extern NSString * const SGKeenSyncRemoteTime;
extern NSString * const SGKeenSyncLocalTime;
extern NSString * const SGKeenCostumeSelectedForVideoSent;

// Sign up session
extern NSString * const SGSignUpSessionToken;


#pragma mark - Onboarding

extern NSString * const kSGOnboardingVersionKey;
extern NSInteger const kSGOnboardingVersion; // Change this when updating any welcome funnel events

extern NSString * const kSGOnboardingEmail;
extern NSString * const kSGOnboardingUsername;
extern NSString * const kSGOnboardingVerifyPhone;
extern NSString * const kSGOnboardingIntro;
extern NSString * const kSGOnboardingMic;
extern NSString * const kSGOnboardingPush;
extern NSString * const kSGOnboardingConvoList;
extern NSString * const kSGOnboardingHowItWorks;
extern NSString * const kSGOnboardingStartConvo;
extern NSString * const kSGOnboardingAllowContacts;
extern NSString * const kSGOnboardingContactList;
extern NSString * const kSGOnboardingPreRecord;
extern NSString * const kSGOnboardingRecording;
extern NSString * const kSGOnboardingFinished;
extern NSString * const kSGOnboardingAllowedKey;
extern NSString * const kSGOnboardingSourceParamKey;
extern NSString * const kSGOnboardingSourceParamStartConvoButtonKey;
extern NSString * const kSGOnboardingSourceParamPlusButtonKey;
extern NSString * const kSGOnboardingSourceParamStartConvoKey;
extern NSString * const kSGOnboardingSourceParamExistingConvoKey;

#pragma mark - Simple Data Store

// in memory
extern NSString * const kSGAccessTokenKey;
extern NSString * const kSGCurrentUser;
extern NSString * const kSGUserIdKey;
extern NSString * const kSGUsernameKey;
extern NSString * const SGCountryCodeKey;
extern NSString * const SGPushToConversationIdKey;
extern NSString * const SGPushToVideoIdKey;
extern NSString * const SGDeviceTokenKey;
extern NSString * const SGNormalizedNumbersKey;
extern NSString * const SGLastConversationColorKey;
extern NSString * const SGVideoPlaybackStart;
extern NSString * const SGDidAttemptToRegisterPushNotifications;
extern NSString * const kSGDidAttemptContactAccess;
extern NSString * const kSGDidFinishWelcomeCreateConversationFlow;
extern NSString * const kSGCreateConversationFlowMode;

// costumes
extern NSString * const SGSelectedCostumeKey;

// first time
extern NSString * const SGFirstTimeWatchAndRespond;
extern NSString * const SGFirstTimeStartingConversation;
extern NSString * const SGFirstTimeLoggedIn;
extern NSString * const SGFirstTimeRecording;
extern NSString * const SGFirstTimeEnteringFakeThread;
extern NSString * const SGFirstTimePreRecording;
extern NSString * const SGFirstTimePostRecording;


// pagination
extern NSString * const SGSyncLastMessageAt;

// archives
extern NSString * const SGArchiveSplitContacts; // list with SG contacts in one array and AB contacts in the other
extern NSString * const SGArchiveMixedContacts; // mixed list of SG & AB contacts
extern NSString * const SGArchiveAddessBookLastModifiedDate;

@end
