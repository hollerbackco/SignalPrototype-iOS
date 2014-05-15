//
//  SGThreadViewController+Info.m
//  SignalPrototype
//
//  Created by Joe Nguyen on 15/05/2014.
//  Copyright (c) 201
//

#import <EXTScope.h>

#import "UIColor+SGHelper.h"

#import "SGThreadViewController+Info.h"
#import "SGMembership+Service.h"


dispatch_queue_t threadInfoViewQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("threadInfoViewQueue", 0);
    });
    return queue;
}

void runOnThreadInfoViewQueue(void (^block)(void))
{
    dispatch_async(threadInfoViewQueue(), block);
}

@implementation SGThreadViewController (Info)

#pragma mark - Views

- (void)setupInfoView
{
    // Overlay view
    self.infoOverlayView.alpha = 0.0;
    self.infoOverlayView.backgroundColor = [JNBlackColor colorWithAlphaComponent:0.5];
    
    self.followersTitleLabel.text = nil;
    self.followersTextView.text = nil;
    
    self.recipientsTitleLabel.text = nil;
    self.recipientsTextView.text = nil;
}

- (void)toggleInfoView
{
    if (self.infoOverlayView.alpha == 0.0) {
        [self showInfoView];
    } else {
        [self hideInfoView];
    }
}

- (void)showInfoView
{
    [self performMemberFetchOnQueue];
    
    [UIView animateWithBlock:^{
        self.infoOverlayView.alpha = 1.0;
    }];
}

- (void)hideInfoView
{
    [UIView animateWithBlock:^{
        self.infoOverlayView.alpha = 0.0;
    }];
}

#pragma mark - Fetch

- (void)performMemberFetchOnQueue
{
    runOnThreadInfoViewQueue(^{
        [self performMemberFetchWithConversationID:self.conversation.identifier completed:^{
            ;
        }];
    });
}

- (void)performMemberFetchWithConversationID:(NSNumber*)conversationID
                                   completed:(void(^)())completed
{   
    @weakify(self);
    [SGMembership getMembersWithConversationID:conversationID completed:^(NSArray *members) {
        [self_weak_
         filterMembers:members
         completed:^(NSArray *followers, NSArray *recipients) {
             
             self_weak_.followers = followers;
             self_weak_.recipients = recipients;
             
             [self_weak_ didFinishFetchingMembers];
         }];
    } failed:^(NSString *errorMessage) {
        [JNAlertView showWithTitle:@"Oops" body:@"Problem getting info"];
    }];
}

- (void)filterMembers:(NSArray*)members
            completed:(void(^)(NSArray *followers, NSArray *recipients))completedBlock
{
    NSMutableArray *followers = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:1];
    
    [members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGMembership *member = (SGMembership*) obj;
        if (member.following.boolValue) {
            [followers addObject:member];
        } else {
            [recipients addObject:member];
        }
    }];
    
    if (completedBlock) {
        completedBlock(followers, recipients);
    }
}

- (void)didFinishFetchingMembers
{
    // followers
    NSUInteger followersCount = self.followers.count;
    [self.followersTitleLabel setText:[NSString stringWithFormat:@"%@ followers:", @(followersCount)]];
    
    __block NSMutableString *followersText = [NSMutableString string];
    [self.followers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGMembership *member = (SGMembership*) obj;
        NSString *username = member.username;
        [followersText appendString:username];
        if (self.followers.count > 1 && idx <= self.followers.count - 2) {
            [followersText appendString:@", "];
        }
    }];
    self.followersTextView.text = followersText;
    
    // recipients
    NSUInteger recipientsCount = self.recipients.count;
    [self.recipientsTitleLabel setText:[NSString stringWithFormat:@"%@ recipients:", @(recipientsCount)]];
    
    __block NSMutableString *recipientsText = [NSMutableString string];
    [self.recipients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGMembership *member = (SGMembership*) obj;
        NSString *username = member.username;
        [recipientsText appendString:username];
        if (self.recipients.count > 1 && idx <= self.recipients.count - 2) {
            [recipientsText appendString:@", "];
        }
    }];
    self.recipientsTextView.text = recipientsText;
}

@end
