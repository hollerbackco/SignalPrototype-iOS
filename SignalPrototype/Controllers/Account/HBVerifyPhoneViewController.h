//
//  HBVerifyPhoneViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JNViewController.h"

@class HBVerifyPhoneViewController;

@protocol HBVerifyPhoneViewDelegate

- (void)controller:(HBVerifyPhoneViewController*)controller didVerifyPhoneForUser:(id)user;
- (void)controllerDidCancel:(HBVerifyPhoneViewController*)controller;

@end

@interface HBVerifyPhoneViewController : JNViewController

@property (nonatomic, weak) id<HBVerifyPhoneViewDelegate> delegate;
@property (nonatomic, copy) NSString *phoneNormalized;

#pragma mark - Actions

- (void)goBackAction:(id)sender;

- (void)nextAction:(id)sender;

- (IBAction)sendPinAction:(id)sender;

@end
