//
//  HBWelcomeFlow.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SGConversation+Service.h"
#import "SGVideo+Service.h"

@interface HBWelcomeFlow : NSObject

@property (nonatomic, strong) UINavigationController *welcomeStartNavigationController;

@property (nonatomic, copy) void(^didLoginBlock)();
@property (nonatomic, copy) void(^finishWelcomeFlowBlock)();

#pragma mark - Start

- (void)startWelcomeFlowCompleted:(void(^)())completed;

#pragma mark - Create Local Convo and Video

+ (BOOL)doesHowItWorksConversationExist;

+ (SGConversation*)createHowItWorksConversation;

+ (SGVideo*)createHowItWorksVideo:(SGConversation*)conversation;

@end
