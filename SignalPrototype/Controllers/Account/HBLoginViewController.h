//
//  HBCreateAccountViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JNViewController.h"

#import "HBRegisterViewController.h"

typedef enum {
    HBLoginViewControllerLoginMode,
    HBLoginViewControllerRegisterMode
} HBLoginViewControllerMode;

@protocol HBLoginViewDelegate

- (void)didCancel;
- (void)didLogin;
- (void)didSignUpWithEmail:(NSString*)email password:(NSString*)password;

@end

@interface HBLoginViewController : JNViewController

@property (nonatomic) HBLoginViewControllerMode mode;
@property (nonatomic, weak) id<HBLoginViewDelegate> delegate;

- (id) initWithTitle:(NSString *)title mode:(HBLoginViewControllerMode)mode delegate:(id)delegate;

- (void) showLegal;

@end
