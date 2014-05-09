//
//  SGConstants.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <AVFoundation/AVCaptureSession.h>

#import "SGConstants.h"

@implementation SGConstants

// API
NSString * const kSGAPIPlatform = @"ios";
NSString * const kSGConversationsLastUpdatedAt = @"conversationsLastUpdatedAt";
CGFloat const kSGRetrySyncDelay = 2.0;
NSUInteger const kSGRetryCount = 3;

// Sync
NSUInteger const kSGSyncPaginationCount = 20;

// Amazon
NSString * const kSGAmazonS3AccessKeyID = @"AKIAIRGS2GLW2KC6JVKQ";
NSString * const kSGAmazonS3SecretKey = @"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";
NSString * const kSGAmazonS3RequestContentTypeVideo = @"video/mp4";
NSString * const kSGAmazonS3RequestContentTypeJPGImage = @"image/jpeg";
NSString * const kSGAmazonS3RequestContentTypePNGImage = @"image/png";
NSString * const kSGAmazonS3RequestContentTypePlainText = @"text/plain";
CGFloat const kSGAmazonPreSignedRequestExpireSeconds = 3600;

// Welcome Flow
NSUInteger const kSGHowItWorksConversationID = INT_MIN;
NSString * const kSGHowItWorksThumbPath = @"https://s3.amazonaws.com/SG-media/batch/howitworks.png";
NSString * const kSGHowItWorksVideoResourceName = @"howitworks";
NSString * const kSGHowItWorksVideoResourceType = @"mp4";

// Contacts
NSUInteger const SGContactsCheckMaxPhoneNumbers = 150;

// Uploads
NSTimeInterval const kSGTransferManagerTimeout = 30.0;
NSTimeInterval const kJNLogFileUploadTimeout = 30.0;
CGFloat const kSGVideoUploadChunkLength = 7.0;
NSUInteger const kSGVideoUploadMaxChunks = 5;
CGFloat const kSGVideoMaxRecordTime = 20.0;
NSTimeInterval const kSGVideoUploadChunkTimeout = 10.0;
NSTimeInterval const kSGFullVideoUploadTimeout = 60.0;
NSTimeInterval const kSGPendingVideoUploadTimeout = 30.0;


// File/Folders
NSString * const kSGTempFolder = @"tmp";
NSString * const kSGTempVideosFolder = @"tmp/videos";
NSInteger const kSGDeleteTempVideosLastModifiedDaysAgo = 1;

// Video
CGFloat const kSGVideoRecordingMinStartTime = 0.2;
CGFloat const kSGVideoRecordingWarningEndTime = 10.0;
CGFloat const kSGVideoCaptureWidth = 480.0;
CGFloat const kSGVideoCaptureHeight = 640.0;
CGFloat const kSGVideoFramesPerSecond = 24.0;
CGFloat const kSGVideoBitRate = 400000;
// old
CGFloat const kSGVideoBitsPerPixel = 2.875;
CGFloat const kSGCameraBlurRadius = 10.0;
CGFloat const kSGThumbBlurRadius = 15.0;

// Video Save
CGFloat const kSGVideoPartsSaveTimeout = 5.0;
NSUInteger const kSGVideoPartsRetryNumberOfTimes = 5;
CGFloat const kSGVideoPartsRetryDelay = 30.0;

// Text Save
CGFloat const kSGTextSaveTimeout = 5.0;
NSUInteger const kSGTextRetryNumberOfTimes = 5;
CGFloat const kSGTextRetryDelay = 30.0;

// Video playback
NSTimeInterval const kSGVideoPlaybackLoadingTimeout = 20.0;
CGFloat const kSGVideoPlaybackLoadingProgressTimeout = 0.2;
NSUInteger const kSGVideoPlaybackNumberOfRecentlyWatchedVideos = 20;

// Messages
NSUInteger const kSGNumberOfRecentlyReadMessages = 20;
NSTimeInterval const kSGSecondsBetweenMessagesForGrouping = 60.0;

// Thread View
NSTimeInterval const kSGSecondsBetweenVideosForGrouping = 60.0;

// Alert view
CGFloat const kSGAlertViewSavedDelay = 1.5;

// Notifications
NSString * const SGShouldRefreshConversationsNotification = @"SGShouldRefreshConversationsNotification";
NSString * const SGNewVideosReceivedNotification = @"SGNewVideosReceivedNotification";

// Filenames
NSString * const kSGVideoExtension = @".mp4";
NSString * const kSGThumbnailExtension = @"-thumb.png";
NSString * const kSGSMSVideoFilename = @"hollerback.mp4";

// iPhone sizes
CGFloat const kSGiPhoneHeight3_5inch = 480.0;
CGFloat const kSGiPhoneHeight4inch = 568.0;
CGFloat const kSGiPhoneStatusBarHeight = 20.0;
CGFloat const kSGiPhoneNavBarHeight = 44.0;

// View
NSString * const SGVideoPaginationStoreKey = @"SGVideoPaginationStoreKey";

// View Tags
int const SGLoadingSpinnerViewTag = 999999;
int const SGVideoPlayerLoadingSpinnerTag = 999998;
int const SGVideoPaginationLoadingSpinnerTag = 999997;
int const SGGroupInfoViewTag = 999996;

// Country Code & Region
int const SGDefaultCountryCode = 1;
NSString * const SGDefaultRegion = @"US";

// Recording Tutorial
CGFloat const kSGTutorialReleaseHoldTime1 = 2.5;
CGFloat const kSGTutorialReleaseHoldTime2 = 4.0;
CGFloat const kSGTutorialReleaseHoldTime3 = 2.5;


+ (BOOL)is4InchiPhone
{
    return [UIScreen mainScreen].bounds.size.height == kSGiPhoneHeight4inch;
}

// Keen Metrics
NSString * const SGKeenDefaultPropertyUserID = @"user_id";
NSString * const SGKeenDefaultPropertyAppVersion = @"app_ver";
NSString * const SGKeenDefaultPropertySkippedTutorial = @"skipped_tutorial";
NSString * const SGKeenDrawerOpen = @"ui:drawer:open";
NSString * const SGKeenVideoDownload = @"ui:video:download";
NSString * const SGKeenVideoUploadStart = @"video:upload:start";
NSString * const SGKeenVideoUploadFirstFail = @"video:upload:first_fail";
NSString * const SGKeenVideoUploadCancel = @"video:upload:cancel";
NSString * const SGKeenVideoUploadComplete = @"video:upload:complete";
NSString * const SGKeenVideoUploadRetries = @"retries";
NSString * const SGKeenVideoUploadTimeToUpload = @"time_to_upload";
NSString * const SGKeenAutoRespondStart = @"video:auto_respond:start";
NSString * const SGKeenAutoRespondQuit = @"video:auto_respond:quit";
NSString * const SGKeenAutoRespondSend = @"video:auto_respond:send";
NSString * const SGKeenBuildContactsTime = @"contacts:build:time";
NSString * const SGKeenQuitCamera = @"quit:camera";
NSString * const SGKeenQuitPlayback = @"quit:playback";
NSString * const SGKeenDidFlipCamera = @"camera:flip";
NSString * const SGKeenVideoRecordFailure = @"video:record:failure";
NSString * const SGKeenConversationHistory = @"ui:conversation:history";
NSString * const SGKeenNewConversationSMSSend = @"ui:new_conversation:sms:send";
NSString * const SGKeenNewConversationSMSCancel = @"ui:new_conversation:sms:cancel";
NSString * const SGKeenFindFriendsSMSSend = @"ui:find_friends:sms:send";
NSString * const SGKeenFindFriendsSMSCancel = @"ui:find_friends:email:cancel";
NSString * const SGKeenFindFriendsEmailSend = @"ui:find_friends:email:send";
NSString * const SGKeenFindFriendsEmailCancel = @"ui:find_friends:sms:cancel";
NSString * const SGKeenVideoTTYLSend = @"video:ttyl:send";
NSString * const SGKeenVideoTTYLCancel = @"video:ttyl:cancel";
NSString * const SGKeenErrorVideoPartsTimeout = @"error:video_parts:timeout";
NSString * const SGKeenException = @"app:exceptions";
NSString * const SGKeenCostumeName = @"camera:costume";
NSString * const SGKeenSyncRemoteTime = @"sync:remote_time";
NSString * const SGKeenSyncLocalTime = @"sync:local_time";
NSString * const SGKeenCostumeSelectedForVideoSent = @"video:sent:costume";

// Sign up session
NSString * const SGSignUpSessionToken = @"session_token";

#pragma mark - Onboarding

NSString * const kSGOnboardingVersionKey                       = @"welcome_ver";
NSInteger const kSGOnboardingVersion                           = 1; // Change this when updating any welcome funnel events

NSString * const kSGOnboardingEmail                             = @"sign_up:email";
NSString * const kSGOnboardingUsername                          = @"sign_up:username";
NSString * const kSGOnboardingVerifyPhone                       = @"sign_up:verify_phone";
NSString * const kSGOnboardingIntro                             = @"sign_up:intro";
NSString * const kSGOnboardingMic                               = @"sign_up:mic";
NSString * const kSGOnboardingPush                              = @"sign_up:push";
NSString * const kSGOnboardingConvoList                         = @"sign_up:convo_list";
NSString * const kSGOnboardingHowItWorks                        = @"sign_up:how_it_works";
NSString * const kSGOnboardingStartConvo                        = @"sign_up:start_convo";
NSString * const kSGOnboardingAllowContacts                     = @"sign_up:allow_contacts";
NSString * const kSGOnboardingContactList                       = @"sign_up:contact_list";
NSString * const kSGOnboardingPreRecord                         = @"sign_up:pre_record";
NSString * const kSGOnboardingRecording                         = @"sign_up:recording";
NSString * const kSGOnboardingFinished                          = @"sign_up:finished";
NSString * const kSGOnboardingAllowedKey                        = @"allowed";
NSString * const kSGOnboardingSourceParamKey                    = @"src_param";
NSString * const kSGOnboardingSourceParamStartConvoButtonKey    = @"start_convo_btn";
NSString * const kSGOnboardingSourceParamPlusButtonKey          = @"plus_btn";
NSString * const kSGOnboardingSourceParamStartConvoKey          = @"start_convo";
NSString * const kSGOnboardingSourceParamExistingConvoKey       = @"existing_convo";

#pragma mark - Simple Data Store

// in memory
NSString * const kSGAccessTokenKey = @"access_token";
NSString * const kSGCurrentUser = @"currentUser";
NSString * const kSGUserIdKey = @"user_id";
NSString * const kSGUsernameKey = @"user_username";
NSString * const SGCountryCodeKey = @"country_code";
NSString * const SGPushToConversationIdKey = @"SGPushToConversationIdKey";
NSString * const SGPushToVideoIdKey = @"SGPushToVideoIdKey";
NSString * const SGDeviceTokenKey = @"SGDeviceTokenKey";
NSString * const SGNormalizedNumbersKey = @"SGNormalizedNumbers";
NSString * const SGLastConversationColorKey = @"SGLastConversationColorKey";
NSString * const SGVideoPlaybackStart = @"SGVideoPlaybackStart";
NSString * const SGDidAttemptToRegisterPushNotifications = @"SGDidAttemptToRegisterPushNotifications";
NSString * const kSGDidAttemptContactAccess = @"kSGDidAttemptContactAccess";
NSString * const kSGDidFinishWelcomeCreateConversationFlow = @"kSGDidFinishWelcomeCreateConversationFlow";
NSString * const kSGCreateConversationFlowMode = @"kSGCreateConversationFlowMode";

// costumes
NSString * const SGSelectedCostumeKey = @"SGSelectedCostume";

// first time
NSString * const SGFirstTimeWatchAndRespond = @"SGFirstTimeWatchAndRespond";
NSString * const SGFirstTimeStartingConversation = @"SGFirstTimeStartingConversation";
NSString * const SGFirstTimeLoggedIn = @"SGFirstTimeLoggedIn";
NSString * const SGFirstTimeRecording = @"SGFirstTimeRecording";
NSString * const SGFirstTimeEnteringFakeThread = @"SGFirstTimeEnteringFakeThread";
NSString * const SGFirstTimePreRecording = @"SGFirstTimePreRecording";
NSString * const SGFirstTimePostRecording = @"SGFirstTimePostRecording";

// pagination
NSString * const SGSyncLastMessageAt = @"SGSyncLastMessageAt";

// archive names
NSString * const SGArchiveSplitContacts = @"SGArchiveSectionsWithContacts";
NSString * const SGArchiveMixedContacts = @"SGArchiveMixedContacts";
NSString * const SGArchiveAddessBookLastModifiedDate = @"SGArchiveAddessBookLastModifiedDate";


@end
