//
//  SGThreadViewController+Follow.h
//  SignalPrototype
//
//  Created by Joe Nguyen on 15/05/2014.
//  Copyright (c) 2014 Signal. All rights reserved.
//

#import "SGThreadViewController.h"

@interface SGThreadViewController (Follow)

- (void)setupFollowingView;

- (void)toggleFollowingWithConversation:(SGConversation*)conversation completed:(void(^)())completed failed:(void(^)())failed;

@end
