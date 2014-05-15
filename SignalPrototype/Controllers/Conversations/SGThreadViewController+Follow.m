//
//  SGThreadViewController+Follow.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 15/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//
#import "UIColor+SGHelper.h"

#import "SGThreadViewController+Follow.h"
#import "SGConversation+Service.h"

@implementation SGThreadViewController (Follow)

- (void)setupFollowingView
{
    [self.followButton setTitle:nil forState:UIControlStateNormal];
    [self.followButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    
    [self updateFollowing:self.conversation.following.boolValue];
}

- (void)toggleFollowingWithConversation:(SGConversation*)conversation completed:(void(^)())completed failed:(void(^)())failed
{
    if (conversation.following.boolValue) {
        
        [self performUnfollowWithConversationID:conversation.identifier completed:^{
            
            [self updateFollowing:NO];
            
            self.conversation.following = @(NO);
            
            [self performMemberFetchOnQueue];
            
        } failed:^{
            ;
        }];
    } else {
        
        [self performFollowWithConversationID:conversation.identifier completed:^{
            
            [self updateFollowing:YES];
            
            self.conversation.following = @(YES);
            
            [self performMemberFetchOnQueue];
            
        } failed:^{
            ;
        }];
    }
}

- (void)performFollowWithConversationID:(NSNumber*)conversationID completed:(void(^)())completed failed:(void(^)())failed
{
    [SGConversation followConversationID:conversationID completed:^{

        if (completed) {
            completed();
        }
        
    } failed:^{
        if (failed) {
            failed();
        }
    }];
}

- (void)performUnfollowWithConversationID:(NSNumber*)conversationID completed:(void(^)())completed failed:(void(^)())failed
{
    [SGConversation unfollowConversationID:conversationID completed:^{
        
        if (completed) {
            completed();
        }
        
    } failed:^{
        if (failed) {
            failed();
        }
    }];
}

- (void)updateFollowing:(BOOL)following
{
    if (following) {
        
        [self.infoButton setTitle:@"following" forState:UIControlStateNormal];
        
        [self.followButton setTitle:@"unfollow" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:JNRedColor];
    } else {
        
        [self.infoButton setTitle:@"not following" forState:UIControlStateNormal];
        
        [self.followButton setTitle:@"follow" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:JNGreenColor];
    }
}

@end
