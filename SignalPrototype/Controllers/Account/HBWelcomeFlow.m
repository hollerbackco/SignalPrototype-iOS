//
//  HBWelcomeFlow.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <EXTScope.h>

#import "SGAppDelegate.h"
#import "SGUser+Service.h"
#import "SGMessage+Service.h"
#import "SGSession.h"

#import "HBWelcomeFlow.h"
#import "HBWelcomeStartViewController.h"

#import "HBLoginViewController.h"
#import "HBRegisterViewController.h"
#import "HBVerifyPhoneViewController.h"

//#import "HBProductDemoViewController.h"
//#import "HBWelcomeIntroViewController.h"
//#import "HBWelcomeAllowMicrophoneViewController.h"
//#import "HBWelcomeAllowContactsViewController.h"
#import "HBWelcomeAllowPushViewController.h"
//#import "HBWelcomeStartConversationViewController.h"
//#import "HBWelcomeCreateGroupViewController.h"
//#import "HBPushNotificationHandler.h"

@interface HBWelcomeFlow () <HBLoginViewDelegate, HBRegisterViewDelegate, HBVerifyPhoneViewDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic) HBLoginViewControllerMode loginMode;

@end

@implementation HBWelcomeFlow

- (void)startWelcomeFlowCompleted:(void(^)())completed
{
    JNLog();
    [self showWelcomeStart];
}

- (void)showWelcomeStart
{
    JNLog();
    HBWelcomeStartViewController *welcomeStartViewController = [[HBWelcomeStartViewController alloc] initWithNib];
    self.welcomeStartNavigationController = [[UINavigationController alloc] initWithRootViewController:welcomeStartViewController];
    [self.welcomeStartNavigationController setNavigationBarHidden:YES];
    @weakify(self);
    //
    welcomeStartViewController.loginBlock = ^() {
        [self_weak_.welcomeStartNavigationController setNavigationBarHidden:NO animated:YES];
        [self_weak_ showLogin];
    };
    //
    welcomeStartViewController.finishedViewController = ^() {
        [self_weak_.welcomeStartNavigationController setNavigationBarHidden:NO animated:YES];
        [self_weak_ showSignUp];
    };
}

#pragma mark - Login

- (void)showLogin
{
    JNLog();
    HBLoginViewController *viewController = [[HBLoginViewController alloc] initWithTitle:@"Log In" mode:HBLoginViewControllerLoginMode delegate:self];
    [self.welcomeStartNavigationController pushViewController:viewController animated:YES];
    self.loginMode = HBLoginViewControllerLoginMode;
}

#pragma mark - Sign Up

- (void)showSignUp
{
    JNLog();
    self.loginMode = HBLoginViewControllerRegisterMode;
    // push to create
    HBLoginViewController *viewController =
    [[HBLoginViewController alloc]
     initWithTitle:JNLocalizedString(@"sign.up.title")
     mode:self.loginMode
     delegate:self];
    viewController.mode = HBLoginViewControllerRegisterMode;
    [self.welcomeStartNavigationController pushViewController:viewController animated:YES];
}

#pragma mark - HBLoginViewDelegate

- (void)didCancel
{
    JNLog();
    [self.welcomeStartNavigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didLogin
{
    JNLog();
    [SGSession sharedInstance].didFinishWelcomeCreateConversationFlow = YES;
    if (self.didLoginBlock) {
        self.didLoginBlock();
    }
}

- (void)didSignUpWithEmail:(NSString*)email password:(NSString*)password
{
    JNLog();
    HBRegisterViewController *viewController =
    [[HBRegisterViewController alloc]
     initWithTitle:JNLocalizedString(@"sign.up.title")
     email:email
     password:password
     delegate:self];
    // next
    [self.welcomeStartNavigationController pushViewController:viewController animated:YES];
}

#pragma mark - HBRegisterViewDelegate

- (void)didRegisterWithPhone:phoneNormalized
{
    JNLog();
    HBVerifyPhoneViewController *viewController = [[HBVerifyPhoneViewController alloc] initWithNibName:@"HBVerifyPhoneViewController" bundle:nil];
    viewController.delegate = self;
    viewController.phoneNormalized = phoneNormalized;
    [self.welcomeStartNavigationController pushViewController:viewController animated:YES];
}

#pragma mark - HBVerifyPhoneViewDelegate

- (void)controller:(HBVerifyPhoneViewController*)controller didVerifyPhoneForUser:(id)user
{
    JNLog();
//    [[HBAppEnterManager sharedInstance] performBackgroundTasks];
    
    // reset first time user settings
    [SGSession setIsFirstTimeEnteringFakeThread:YES];
    [SGSession setIsFirstTimePreRecording:YES];
    [SGSession setIsFirstTimePostRecording:YES];
    
    [self startAllowAccessFlow:^{
        
    }];
}

- (void)controllerDidCancel:(HBVerifyPhoneViewController*)controller
{
    JNLog();
    [controller.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Allow Access Flow

- (void)startAllowAccessFlow:(void(^)())completed
{
    JNLog();
    [self.welcomeStartNavigationController setNavigationBarHidden:YES animated:YES];
    
    [self moveToAllowPush];
}

- (void)moveToAllowPush
{
    JNLog();
    HBWelcomeAllowPushViewController *welcomeAllowPushViewController = [[HBWelcomeAllowPushViewController alloc] initWithNib];
    [self.welcomeStartNavigationController pushViewController:welcomeAllowPushViewController animated:YES];
    @weakify(self);
    welcomeAllowPushViewController.finishedViewController = ^() {
        runOnMainQueue(^{
//            if (![self.class doesHowItWorksConversationExist]) {
//                [self.class createHowItWorksConversation];
//            }
            [self_weak_ finishedWelcomeFlow];
        });
    };
}

#pragma mark - Create Local Convo and Video

+ (BOOL)doesHowItWorksConversationExist
{
    __block BOOL doesHowItWorksConversationExist = NO;
    [SGConversation
     fetchByID:@(kSGHowItWorksConversationID)
     success:^(SGConversation *conversation) {
        if (conversation) {
            doesHowItWorksConversationExist = YES;
        }
    } fail:^(NSString *error) {
        JNLogObject(error);
    }];
    return doesHowItWorksConversationExist;
}

+ (SGConversation*)createHowItWorksConversation
{
    SGConversation *conversation = [SGConversation new];
    conversation.identifier = @(kSGHowItWorksConversationID);
    conversation.lastMessageAt = [NSDate date];
    conversation.name = JNLocalizedString(@"convo.list.how.it.works.title");
    conversation.mostRecentThumbURL = [[NSBundle mainBundle] URLForResource:@"banana-thumb" withExtension:@"png"].absoluteString;
    conversation.unreadCount = @(0);
    conversation.isDeleted = @(NO);
    [conversation save];
    return conversation;
}

+ (SGVideo*)createHowItWorksVideo:(SGConversation*)conversation
{
    NSNumber *conversationID = conversation.identifier;
    NSDate *sentAt = [NSDate date];
    NSNumber *senderID = @(0);
    NSString *senderName = @"";
    NSString *videoGUID = [SGVideo generateGUID];
    NSNumber *isRead = @(NO);
    
    // create message and save locally
    SGMessage  *message = [SGMessage new];
    message.contentGUID = videoGUID;
    message.messageType = kSGMessageTypeVideo;
    message.conversationID = conversationID;
    message.sentAt = sentAt;
    message.senderID = senderID;
    message.senderName = senderName;
    message.isRead = isRead;
    [message save];
    
    SGVideo *video = [SGVideo new];
    video.guid = videoGUID;
    video.conversationID = conversation.identifier;
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:kSGHowItWorksVideoResourceName ofType:kSGHowItWorksVideoResourceType];
    video.url = ((NSURL*) [NSURL fileURLWithPath:videoPath isDirectory:NO]).absoluteString;
    video.thumbURL = conversation.mostRecentThumbURL;
    video.isRead = isRead;
    video.senderID = senderID;
    video.senderName = senderName;
    video.sentAt = sentAt;
    [video save];
    
    return video;
}

#pragma mark - Finished Welcome Flow

- (void)finishedWelcomeFlow
{
    JNLog();
    [[SGSession sharedInstance] didFinishWelcomeFlow];
    if (self.finishWelcomeFlowBlock) {
        self.finishWelcomeFlowBlock();
    }
}

@end
